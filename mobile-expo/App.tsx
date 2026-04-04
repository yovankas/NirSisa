import React, { useState, useCallback } from "react";
import { View, Text, StyleSheet, ActivityIndicator } from "react-native";
import { useFonts, Inter_600SemiBold, Inter_700Bold } from "@expo-google-fonts/inter";
import SplashScreen from "./src/screens/SplashScreen";

const App: React.FC = () => {
  const [isSplashDone, setIsSplashDone] = useState(false);

  const [fontsLoaded] = useFonts({
    Inter_600SemiBold,
    Inter_700Bold,
  });

  const handleSplashFinish = useCallback(() => {
    setTimeout(() => {
      setIsSplashDone(true);
    }, 400);
  }, []);

  if (!fontsLoaded) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#BB0009" />
      </View>
    );
  }

  if (!isSplashDone) {
    return <SplashScreen onFinish={handleSplashFinish} />;
  }

  return (
    <View style={styles.mainContainer}>
      <Text style={styles.placeholderText}>Selamat datang di NirSisa!</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  loadingContainer: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "#C4967A",
  },
  mainContainer: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "#FAFAFA",
  },
  placeholderText: {
    fontSize: 20,
    fontFamily: "Inter_600SemiBold",
    color: "#2B2B2B",
  },
});

export default App;