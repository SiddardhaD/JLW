package com.example.ui.theme

import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext

private val DarkColorScheme =
  darkColorScheme(
    primary = JLWThemeMintAccent,
    onPrimary = JLWThemeDarkText,
    secondary = JLWThemeCardBg,
    onSecondary = JLWThemeWhite,
    tertiary = JLWStatusUrgent,
    background = JLWThemeDarkBg,
    onBackground = JLWThemeWhite,
    surface = JLWThemeCardBg,
    onSurface = JLWThemeWhite,
    surfaceVariant = JLWThemeInputBg,
    onSurfaceVariant = JLWThemeSlateText,
    outline = JLWBorderColor
  )

private val LightColorScheme = DarkColorScheme // Enterprise app stays strictly dark theme as per mockup

@Composable
fun MyApplicationTheme(
  darkTheme: Boolean = true, // Force dark theme to match mockups exactly
  dynamicColor: Boolean = false, // Disable dynamic colors to enforce JLW identity
  content: @Composable () -> Unit,
) {
  val colorScheme = DarkColorScheme // Standard corporate brand dark theme

  MaterialTheme(colorScheme = colorScheme, typography = Typography, content = content)
}
