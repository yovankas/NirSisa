import React, { useEffect, useRef, useState } from "react";
import {
  View,
  Image,
  Text,
  StyleSheet,
  Animated,
  Dimensions,
  StatusBar,
  ImageBackground,
} from "react-native";
import MaskedView from "@react-native-masked-view/masked-view";
import { LinearGradient } from "expo-linear-gradient";

const { width: SCREEN_WIDTH, height: SCREEN_HEIGHT } = Dimensions.get("window");

const PROGRESS_BAR_WIDTH = SCREEN_WIDTH * 0.62;
const PROGRESS_BAR_HEIGHT = 5;
const PROGRESS_DURATION = 3000;

const BG_IMAGE = require("../assets/images/bg_splash.png");
const LOGO_IMAGE = require("../assets/images/logo.png");

interface SplashScreenProps {
  onFinish?: () => void;
}

const GradientText: React.FC<{
  text: string;
  colors: [string, string, ...string[]];
  style: any;
}> = ({ text, colors, style }) => {
  return (
    <MaskedView
      maskElement={
        <Text style={[style, { backgroundColor: "transparent" }]}>{text}</Text>
      }
    >
      <LinearGradient
        colors={colors}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 0 }}
      >
        <Text style={[style, { opacity: 0 }]}>{text}</Text>
      </LinearGradient>
    </MaskedView>
  );
};

const SplashScreen: React.FC<SplashScreenProps> = ({ onFinish }) => {
  const [bgReady, setBgReady] = useState(false);

  const progress = useRef(new Animated.Value(0)).current;
  const logoOpacity = useRef(new Animated.Value(0)).current;
  const logoScale = useRef(new Animated.Value(0.92)).current;
  const textOpacity = useRef(new Animated.Value(0)).current;
  const barOpacity = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    if (!bgReady) return;

    Animated.sequence([
      Animated.parallel([
        Animated.timing(logoOpacity, {
          toValue: 1,
          duration: 650,
          useNativeDriver: true,
        }),
        Animated.timing(logoScale, {
          toValue: 1,
          duration: 650,
          useNativeDriver: true,
        }),
      ]),
      Animated.timing(textOpacity, {
        toValue: 1,
        duration: 350,
        useNativeDriver: true,
      }),
      Animated.parallel([
        Animated.timing(barOpacity, {
          toValue: 1,
          duration: 250,
          useNativeDriver: true,
        }),
        Animated.timing(progress, {
          toValue: 1,
          duration: PROGRESS_DURATION,
          useNativeDriver: false,
        }),
      ]),
    ]).start(() => {
      onFinish?.();
    });
  }, [bgReady]);

  const barWidth = progress.interpolate({
    inputRange: [0, 1],
    outputRange: [0, PROGRESS_BAR_WIDTH * 0.34],
  });

  return (
    <View style={styles.container}>
      <StatusBar
        translucent
        backgroundColor="transparent"
        barStyle="dark-content"
      />

      <ImageBackground
        source={BG_IMAGE}
        style={styles.background}
        resizeMode="cover"
        onLoadEnd={() => setBgReady(true)}
      >
        <View style={styles.overlay} />

        <View style={styles.content}>
          <Animated.View
            style={[
              styles.logoContainer,
              {
                opacity: logoOpacity,
                transform: [{ scale: logoScale }],
              },
            ]}
          >
            <Image
              source={LOGO_IMAGE}
              style={styles.logo}
              resizeMode="contain"
            />
          </Animated.View>

          <Animated.View style={{ opacity: textOpacity }}>
            <Text style={styles.appName}>NirSisa</Text>
          </Animated.View>

          <Animated.View style={{ opacity: textOpacity, marginTop: 6 }}>
            <GradientText
              text="Cipta Rasa, Jaga Sisa."
              colors={["#B52A24", "#E4A23A"]}
              style={styles.tagline}
            />
          </Animated.View>

          <Animated.View
            style={[styles.progressContainer, { opacity: barOpacity }]}
          >
            <View style={styles.progressTrack}>
              <Animated.View
                style={[styles.progressFill, { width: barWidth }]}
              />
            </View>
          </Animated.View>
        </View>
      </ImageBackground>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#EED6CC",
  },
  background: {
    flex: 1,
    width: SCREEN_WIDTH,
    height: SCREEN_HEIGHT,
  },
  overlay: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: "rgba(255, 240, 235, 0.25)",
  },
  content: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
    paddingBottom: SCREEN_HEIGHT * 0.06,
  },
  logoContainer: {
    width: SCREEN_WIDTH * 0.64,
    height: SCREEN_WIDTH * 0.64 * 0.58,
    marginBottom: 16,
  },
  logo: {
    width: "100%",
    height: "100%",
  },
  appName: {
    fontFamily: "Inter_700Bold",
    fontSize: 44,
    color: "#B30018",
    lineHeight: 50,
    letterSpacing: -0.8,
    textAlign: "center",
  },
  tagline: {
    fontFamily: "Inter_600SemiBold",
    fontSize: 18,
    lineHeight: 24,
    letterSpacing: -0.2,
    textAlign: "center",
  },
  progressContainer: {
    marginTop: 44,
    alignItems: "center",
  },
  progressTrack: {
    width: PROGRESS_BAR_WIDTH,
    height: PROGRESS_BAR_HEIGHT,
    borderRadius: 999,
    backgroundColor: "rgba(120, 95, 90, 0.20)",
    overflow: "hidden",
  },
  progressFill: {
    height: "100%",
    borderRadius: 999,
    backgroundColor: "#D93025",
  },
});

export default SplashScreen;