import React, { useEffect, useMemo, useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Image,
  Platform,
  ActivityIndicator,
  Alert,
} from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { ChefAIStackParamList } from "../navigation/AppNavigator";
// ▼▼▼ FIX: ganti dummy data ke API client + types ▼▼▼
import { api, extractApiError } from "../services/api";
import {
  InventoryItemResponse,
  ReconciliationRequest,
  ReconciliationResponse,
} from "../types/api";
import { capitalizeEachWord } from "../utils/formatters";
// ▲▲▲

const LOGO_IMAGE = require("../assets/images/logo.png");

type Props = NativeStackScreenProps<ChefAIStackParamList, "RecipeDetail">;

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Parse string ingredients/steps mentah dari dataset.
 * Format dataset Indonesian Food Recipes biasanya pakai "--" sebagai delimiter
 * antar item, tapi kadang juga newline. Coba dua-duanya.
 */
const parseRawList = (raw: string): string[] => {
  if (!raw) return [];
  // Coba split "--" dulu (format Cookpad/Kaggle)
  let parts = raw.split("--").map((s) => s.trim()).filter(Boolean);
  // Kalau cuma 1 item, fallback ke newline
  if (parts.length <= 1) {
    parts = raw.split(/\r?\n/).map((s) => s.trim()).filter(Boolean);
  }
  // Bersihkan numbering "1. ", "1) " di awal
  return parts.map((p) => p.replace(/^\d+[.)]\s*/, ""));
};

/**
 * Local view model untuk satu baris bahan di UI.
 * Sebelumnya dari dummy `Ingredient` type. Sekarang dibangun client-side
 * dari recipe.ingredients (raw text) + matching ke user inventory.
 */
interface IngredientView {
  id: string;
  text: string;            // teks asli dari dataset
  matchedItem: InventoryItemResponse | null; // null = user tidak punya bahan ini
}

interface StepView {
  id: string;
  number: number;
  text: string;
}

// ─────────────────────────────────────────────────────────────────────────────
// SUB-COMPONENTS
// ─────────────────────────────────────────────────────────────────────────────

const IngredientRow: React.FC<{ item: IngredientView }> = ({ item }) => {
  const isAvailable = item.matchedItem !== null;
  return (
    <View style={styles.ingredientRow}>
      <View style={styles.ingredientInfo}>
        <Text style={styles.ingredientName}>{item.text}</Text>
        <Text
          style={[
            styles.ingredientSub,
            !isAvailable && styles.ingredientSubInsufficient,
          ]}
        >
          {isAvailable
            ? `Tersedia: ${item.matchedItem!.quantity} ${item.matchedItem!.unit || ""}`
            : "Tidak ada di stok"}
        </Text>
      </View>
      <View
        style={[
          styles.ingredientStatus,
          isAvailable ? styles.ingredientStatusGreen : styles.ingredientStatusRed,
        ]}
      >
        <Ionicons name={isAvailable ? "checkmark" : "close"} size={16} color="#FFFFFF" />
      </View>
    </View>
  );
};

const StepRow: React.FC<{ item: StepView; isLast: boolean }> = ({ item, isLast }) => (
  <View style={styles.stepRow}>
    <View style={styles.stepLeft}>
      <View style={styles.stepCircle}>
        <Text style={styles.stepNumber}>{item.number}</Text>
      </View>
      {!isLast && <View style={styles.stepLine} />}
    </View>
    <View style={[styles.stepContent, isLast && { marginBottom: 0 }]}>
      <Text style={styles.stepDescription}>{item.text}</Text>
    </View>
  </View>
);

// ─────────────────────────────────────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────────────────────────────────────

const RecipeDetailScreen: React.FC<Props> = ({ route, navigation }) => {
  // ▼▼▼ FIX: ambil recipe dari route params, bukan lookup di dummy RECIPES ▼▼▼
  const { recipe } = route.params;
  // ▲▲▲

  const [inventory, setInventory] = useState<InventoryItemResponse[]>([]);
  const [loadingInventory, setLoadingInventory] = useState(true);
  const [reconciling, setReconciling] = useState(false);

  // Fetch user inventory untuk matching
  useEffect(() => {
    (async () => {
      try {
        const res = await api.get<InventoryItemResponse[]>("/inventory");
        setInventory(res.data || []);
      } catch (err) {
        console.warn("[RecipeDetail] gagal fetch inventory:", extractApiError(err));
      } finally {
        setLoadingInventory(false);
      }
    })();
  }, []);

  // Parse ingredients & steps + match dengan inventory user
  const ingredientList: IngredientView[] = useMemo(() => {
    const lines = parseRawList(recipe.ingredients);
    return lines.map((text, idx) => {
      // Match: cek apakah salah satu inventory item name muncul di teks ingredient
      const matched = inventory.find((inv) => {
        const invName = (inv.item_name_normalized || inv.item_name || "").toLowerCase().trim();
        if (!invName) return false;
        return text.toLowerCase().includes(invName);
      }) || null;
      return { id: `ing-${idx}`, text, matchedItem: matched };
    });
  }, [recipe.ingredients, inventory]);

  const stepList: StepView[] = useMemo(() => {
    return parseRawList(recipe.steps).map((text, idx) => ({
      id: `step-${idx}`,
      number: idx + 1,
      text,
    }));
  }, [recipe.steps]);

  // List bahan user yang akan dikurangi saat masak
  const itemsToConsume = useMemo(() => {
    const matched = ingredientList
      .map((i) => i.matchedItem)
      .filter((x): x is InventoryItemResponse => x !== null);
    // Dedupe by id (kalau bahan yang sama match ke beberapa baris ingredient)
    const seen = new Set<string>();
    return matched.filter((item) => {
      if (seen.has(item.id)) return false;
      seen.add(item.id);
      return true;
    });
  }, [ingredientList]);

  const hasInsufficient = ingredientList.some((i) => i.matchedItem === null);

  // ─────────────────────────────────────────────────────────────────────────
  // RECONCILIATION HANDLER
  // ─────────────────────────────────────────────────────────────────────────
  const handleKonfirmasiMasak = async () => {
    if (itemsToConsume.length === 0) {
      Alert.alert(
        "Tidak Ada Bahan",
        "Tidak ada bahan di stok Anda yang cocok dengan resep ini. Pastikan stok bahan sudah ditambahkan."
      );
      return;
    }

    const summary = itemsToConsume
      .map((it) => `• ${capitalizeEachWord(it.item_name)} (1 ${it.unit || "unit"})`)
      .join("\n");

    Alert.alert(
      "Konfirmasi Masak",
      `Bahan berikut akan dikurangi dari stok Anda:\n\n${summary}\n\nLanjutkan?`,
      [
        { text: "Batal", style: "cancel" },
        {
          text: "Ya, Masak",
          style: "destructive",
          onPress: doReconcile,
        },
      ]
    );
  };

  const doReconcile = async () => {
    setReconciling(true);
    try {
      // Default deduct: 1 unit per matched item, dibatasi current quantity.
      // Strategi sederhana untuk MVP — bisa di-upgrade nanti jadi modal
      // dengan input quantity per item.
      const payload: ReconciliationRequest = {
        // recipe_id sengaja TIDAK dikirim — karena recipe.index dari recommender
        // itu row pickle, BUKAN DB primary key. Backend sudah handle ini sebagai
        // optional dan akan tetap mencatat history dengan recipe_title.
        recipe_title: recipe.title,
        ingredients_used: itemsToConsume.map((it) => ({
          item_id: it.id,
          quantity_used: Math.min(1, it.quantity),
        })),
      };

      const res = await api.post<ReconciliationResponse>("/inventory/reconcile", payload);
      const data = res.data;

      const updatedCount = data.items_updated.length;
      const removedCount = data.items_removed.length;

      Alert.alert(
        "Berhasil Masak! 🎉",
        `${updatedCount} bahan dikurangi, ${removedCount} bahan habis.\n\nResep tersimpan di Riwayat.`,
        [{ text: "OK", onPress: () => navigation.goBack() }]
      );
    } catch (err) {
      const msg = extractApiError(err);
      Alert.alert("Gagal", `Tidak bisa memproses: ${msg}`);
    } finally {
      setReconciling(false);
    }
  };

  return (
    <View style={styles.flex}>
      <ScrollView
        style={styles.flex}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        {/* Header */}
        <View style={styles.header}>
          <TouchableOpacity style={styles.backButton} onPress={() => navigation.goBack()}>
            <Ionicons name="chevron-back" size={22} color="#2B2B2B" />
          </TouchableOpacity>
          <Image source={LOGO_IMAGE} style={styles.logoSmall} resizeMode="contain" />
          <TouchableOpacity style={styles.heartButton}>
            <Ionicons name="heart-outline" size={22} color="#2B2B2B" />
          </TouchableOpacity>
        </View>

        {/* Title */}
        <Text style={styles.title}>{capitalizeEachWord(recipe.title)}</Text>

        {/* Match percentage banner */}
        <View style={styles.matchBanner}>
          <Ionicons name="sparkles" size={16} color="#BB0009" />
          <Text style={styles.matchBannerText}>
            {recipe.match_percentage.toFixed(0)}% bahan Anda cocok • Skor final{" "}
            {(recipe.final_score * 100).toFixed(0)}%
          </Text>
        </View>

        {/* Warning Banner */}
        {hasInsufficient && (
          <View style={styles.warningBanner}>
            <Ionicons name="information-circle" size={20} color="#D97706" style={styles.warningIcon} />
            <Text style={styles.warningText}>
              Beberapa bahan tidak ada di stok Anda. Anda tetap bisa masak, namun pastikan
              membeli bahan yang kurang terlebih dahulu.
            </Text>
          </View>
        )}

        {/* Bahan-Bahan */}
        <View style={styles.sectionHeader}>
          <Text style={styles.sectionTitle}>Bahan-Bahan</Text>
          <Text style={styles.sectionMeta}>{ingredientList.length} item total</Text>
        </View>

        {loadingInventory ? (
          <ActivityIndicator color="#BB0009" style={{ marginVertical: 20 }} />
        ) : (
          <View style={styles.card}>
            {ingredientList.map((item, index) => (
              <View key={item.id}>
                <IngredientRow item={item} />
                {index < ingredientList.length - 1 && <View style={styles.separator} />}
              </View>
            ))}
          </View>
        )}

        {/* Langkah-Langkah */}
        <Text style={[styles.sectionTitle, { marginTop: 28, marginBottom: 16 }]}>
          Langkah-Langkah
        </Text>
        <View style={styles.card}>
          {stepList.map((step, index) => (
            <StepRow key={step.id} item={step} isLast={index === stepList.length - 1} />
          ))}
        </View>

        <View style={{ height: 32 }} />
      </ScrollView>

      {/* Sticky Bottom Button */}
      <View style={styles.bottomBar}>
        <TouchableOpacity
          style={[styles.confirmButton, reconciling && { opacity: 0.6 }]}
          activeOpacity={0.85}
          onPress={handleKonfirmasiMasak}
          disabled={reconciling}
        >
          {reconciling ? (
            <ActivityIndicator color="#FFFFFF" />
          ) : (
            <Text style={styles.confirmButtonText}>Konfirmasi Masak</Text>
          )}
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  flex: {
    flex: 1,
    backgroundColor: "#FAFAFA",
  },
  scrollContent: {
    paddingHorizontal: 24,
    paddingTop: Platform.OS === "ios" ? 60 : 40,
    paddingBottom: 20,
  },
  header: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    marginBottom: 24,
  },
  backButton: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: "#F0F0F0",
    alignItems: "center",
    justifyContent: "center",
  },
  logoSmall: {
    width: 56,
    height: 32,
  },
  heartButton: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: "#F0F0F0",
    alignItems: "center",
    justifyContent: "center",
  },
  title: {
    fontFamily: "Inter_700Bold",
    fontSize: 28,
    color: "#2B2B2B",
    lineHeight: 36,
    marginBottom: 12,
  },
  matchBanner: {
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
    backgroundColor: "#FEF2F2",
    paddingHorizontal: 14,
    paddingVertical: 10,
    borderRadius: 10,
    marginBottom: 16,
    alignSelf: "flex-start",
  },
  matchBannerText: {
    fontFamily: "Inter_700Bold",
    fontSize: 12,
    color: "#BB0009",
    letterSpacing: 0.3,
  },
  warningBanner: {
    flexDirection: "row",
    backgroundColor: "#FFFBEB",
    borderRadius: 12,
    borderWidth: 1,
    borderColor: "#FDE68A",
    padding: 14,
    marginBottom: 24,
    alignItems: "flex-start",
  },
  warningIcon: {
    marginRight: 10,
    marginTop: 1,
  },
  warningText: {
    flex: 1,
    fontFamily: "Inter_400Regular",
    fontSize: 13,
    color: "#92400E",
    lineHeight: 19,
  },
  sectionHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 14,
  },
  sectionTitle: {
    fontFamily: "Inter_700Bold",
    fontSize: 18,
    color: "#2B2B2B",
  },
  sectionMeta: {
    fontFamily: "Inter_400Regular",
    fontSize: 13,
    color: "#949FA2",
  },
  card: {
    backgroundColor: "#FFFFFF",
    borderRadius: 16,
    borderWidth: 1,
    borderColor: "#F0F0F0",
    paddingHorizontal: 16,
    paddingVertical: 4,
  },
  // ── Ingredients ──
  ingredientRow: {
    flexDirection: "row",
    alignItems: "center",
    paddingVertical: 14,
    gap: 12,
  },
  ingredientInfo: {
    flex: 1,
  },
  ingredientName: {
    fontFamily: "Inter_600SemiBold",
    fontSize: 14,
    color: "#2B2B2B",
    marginBottom: 2,
  },
  ingredientSub: {
    fontFamily: "Inter_400Regular",
    fontSize: 12,
    color: "#949FA2",
  },
  ingredientSubInsufficient: {
    color: "#BB0009",
  },
  ingredientStatus: {
    width: 28,
    height: 28,
    borderRadius: 14,
    alignItems: "center",
    justifyContent: "center",
  },
  ingredientStatusGreen: {
    backgroundColor: "#15803D",
  },
  ingredientStatusRed: {
    backgroundColor: "#BB0009",
  },
  separator: {
    height: 1,
    backgroundColor: "#F5F5F5",
    marginLeft: 0,
  },
  // ── Steps ──
  stepRow: {
    flexDirection: "row",
    paddingTop: 16,
  },
  stepLeft: {
    alignItems: "center",
    width: 32,
    marginRight: 14,
  },
  stepCircle: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: "#BB0009",
    alignItems: "center",
    justifyContent: "center",
  },
  stepNumber: {
    fontFamily: "Inter_700Bold",
    fontSize: 14,
    color: "#FFFFFF",
  },
  stepLine: {
    flex: 1,
    width: 2,
    backgroundColor: "#F0F0F0",
    marginTop: 6,
    marginBottom: 0,
    minHeight: 20,
  },
  stepContent: {
    flex: 1,
    paddingBottom: 20,
  },
  stepDescription: {
    fontFamily: "Inter_400Regular",
    fontSize: 13,
    color: "#656C6E",
    lineHeight: 19,
    marginTop: 6,
  },
  // ── Bottom Bar ──
  bottomBar: {
    backgroundColor: "#FFFFFF",
    paddingHorizontal: 24,
    paddingTop: 12,
    paddingBottom: Platform.OS === "ios" ? 32 : 16,
    borderTopWidth: 1,
    borderTopColor: "#F0F0F0",
  },
  confirmButton: {
    backgroundColor: "#BB0009",
    borderRadius: 14,
    paddingVertical: 16,
    alignItems: "center",
  },
  confirmButtonText: {
    fontFamily: "Inter_700Bold",
    fontSize: 16,
    color: "#FFFFFF",
  },
});

export default RecipeDetailScreen;