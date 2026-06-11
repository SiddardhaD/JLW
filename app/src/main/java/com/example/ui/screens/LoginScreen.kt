package com.example.ui.screens

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Fingerprint
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.SentimentSatisfiedAlt
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.ui.theme.*
import com.example.ui.viewmodel.ApprovalsViewModel

/**
 * Screen 1: Sign In screen.
 * Replicates the elegant "JLW Corporate Access" design mockup.
 *
 * For Flutter Developers:
 * - This screen represents a [Scaffold] with a [SingleChildScrollView] / [Column]
 * - Input text fields are styled similarly to Flutter's [InputDecoration] + [TextField]
 * - State flow acts like [StreamBuilder] or [ValueListenableBuilder]
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LoginScreen(
    viewModel: ApprovalsViewModel,
    onLoginSuccess: () -> Unit
) {
    val username by viewModel.username.collectAsState()
    val password by viewModel.password.collectAsState()
    val isAuthenticated by viewModel.isAuthenticated.collectAsState()
    val errorMsg by viewModel.loginError.collectAsState()

    // Trigger navigation side-effect when successfully logged in
    LaunchedEffect(isAuthenticated) {
        if (isAuthenticated) {
            onLoginSuccess()
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(JLWThemeDarkBg)
            .imePadding() // Automatically lifts UI above software keyboard
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 24.dp)
                .verticalScroll(rememberScrollState()),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Spacer(modifier = Modifier.height(28.dp))

            // JLW Header Brand Styling
            Text(
                text = "JLW",
                color = Color.White,
                fontSize = 52.sp,
                fontFamily = FontFamily.Serif,
                fontWeight = FontWeight.Bold,
                letterSpacing = 1.sp,
                textAlign = TextAlign.Center
            )
            
            Text(
                text = "SINCE 1875",
                color = JLWThemeSlateText,
                fontSize = 11.sp,
                fontWeight = FontWeight.Medium,
                letterSpacing = 4.sp,
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(top = 8.dp)
            )

            // Green decorative underline bar
            Box(
                modifier = Modifier
                    .padding(top = 16.dp, bottom = 28.dp)
                    .width(48.dp)
                    .height(2.dp)
                    .background(JLWThemeMintAccent)
            )

            // Login Box Container (Rounded Card in Dark Slate Navy)
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(12.dp))
                    .background(JLWThemeCardBg)
                    .border(BorderStroke(1.dp, JLWBorderColor), RoundedCornerShape(12.dp))
                    .padding(24.dp)
            ) {
                Text(
                    text = "Sign In",
                    color = Color.White,
                    fontSize = 20.sp,
                    fontFamily = FontFamily.Serif,
                    fontWeight = FontWeight.Bold,
                    textAlign = TextAlign.Center,
                    modifier = Modifier.fillMaxWidth()
                )

                Text(
                    text = "SECURE ENTERPRISE ACCESS",
                    color = JLWThemeSlateText,
                    fontSize = 10.sp,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 1.sp,
                    textAlign = TextAlign.Center,
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(top = 8.dp, bottom = 24.dp)
                )

                // Label: USER NAME
                Text(
                    text = "USER NAME",
                    color = JLWThemeSlateText,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.padding(bottom = 6.dp)
                )

                // Input: USER NAME
                OutlinedTextField(
                    value = username,
                    onValueChange = { viewModel.onUsernameChange(it) },
                    placeholder = {
                        Text(
                            text = "Enter identity ID",
                            color = JLWThemeSlateText.copy(alpha = 0.8f),
                            fontSize = 15.sp
                        )
                    },
                    leadingIcon = {
                        Icon(
                            imageVector = Icons.Default.Person,
                            contentDescription = "User Identity ID Icon",
                            tint = JLWThemeSlateText
                        )
                    },
                    singleLine = true,
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = JLWBorderFocused,
                        unfocusedBorderColor = JLWBorderColor,
                        focusedContainerColor = JLWThemeInputBg,
                        unfocusedContainerColor = JLWThemeInputBg,
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White
                    ),
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(bottom = 20.dp)
                        .testTag("username_input")
                )

                // Label: PASSWORD
                Text(
                    text = "PASSWORD",
                    color = JLWThemeSlateText,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.padding(bottom = 6.dp)
                )

                // Input: PASSWORD
                OutlinedTextField(
                    value = password,
                    onValueChange = { viewModel.onPasswordChange(it) },
                    placeholder = {
                        Text(
                            text = "••••••••",
                            color = JLWThemeSlateText.copy(alpha = 0.8f),
                            fontSize = 15.sp
                        )
                    },
                    leadingIcon = {
                        Icon(
                            imageVector = Icons.Default.Lock,
                            contentDescription = "Password Security Lock Icon",
                            tint = JLWThemeSlateText
                        )
                    },
                    singleLine = true,
                    visualTransformation = PasswordVisualTransformation(),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = JLWBorderFocused,
                        unfocusedBorderColor = JLWBorderColor,
                        focusedContainerColor = JLWThemeInputBg,
                        unfocusedContainerColor = JLWThemeInputBg,
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White
                    ),
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(bottom = 24.dp)
                        .testTag("password_input")
                )

                // Login Error message if any
                if (errorMsg != null) {
                    Text(
                        text = errorMsg ?: "",
                        color = JLWStatusHighValue,
                        fontSize = 13.sp,
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(bottom = 12.dp),
                        textAlign = TextAlign.Center
                    )
                }

                // LOGIN BUTTON (Shiny Mint Green)
                Button(
                    onClick = { viewModel.login() },
                    colors = ButtonDefaults.buttonColors(
                        containerColor = JLWThemeMintAccent,
                        contentColor = JLWThemeDarkText
                    ),
                    shape = RoundedCornerShape(8.dp),
                    contentPadding = PaddingValues(vertical = 14.dp),
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(bottom = 24.dp)
                        .testTag("login_button")
                ) {
                    Text(
                        text = "LOGIN",
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 1.sp,
                        fontSize = 15.sp
                    )
                }

                // BIOMETRIC AUTH Divider
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(bottom = 18.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    HorizontalDivider(
                        modifier = Modifier.weight(1f),
                        color = JLWBorderColor
                    )
                    Text(
                        text = "BIOMETRIC AUTH",
                        color = JLWThemeSlateText,
                        fontSize = 10.sp,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 0.5.sp,
                        modifier = Modifier.padding(horizontal = 12.dp)
                    )
                    HorizontalDivider(
                        modifier = Modifier.weight(1f),
                        color = JLWBorderColor
                    )
                }

                // Biometrics Buttons: Face ID and Fingerprint Row
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    // Face ID
                    Column(
                        modifier = Modifier
                            .weight(1f)
                            .clip(RoundedCornerShape(8.dp))
                            .border(BorderStroke(1.dp, JLWBorderColor), RoundedCornerShape(8.dp))
                            .clickable {
                                // Simulate Face ID biometric success
                                viewModel.onUsernameChange("1234567")
                                viewModel.onPasswordChange("demo_pass")
                                viewModel.login()
                            }
                            .padding(vertical = 12.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.Center
                    ) {
                        Icon(
                            imageVector = Icons.Default.SentimentSatisfiedAlt,
                            contentDescription = "Face ID biometric scanner",
                            tint = JLWThemeMintAccent,
                            modifier = Modifier.size(24.dp)
                        )
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            text = "Face ID",
                            color = Color.White,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }

                    // Fingerprint
                    Column(
                        modifier = Modifier
                            .weight(1f)
                            .clip(RoundedCornerShape(8.dp))
                            .border(BorderStroke(1.dp, JLWBorderColor), RoundedCornerShape(8.dp))
                            .clickable {
                                // Simulate Fingerprint biometric success
                                viewModel.onUsernameChange("1234567")
                                viewModel.onPasswordChange("demo_pass")
                                viewModel.login()
                            }
                            .padding(vertical = 12.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.Center
                    ) {
                        Icon(
                            imageVector = Icons.Default.Fingerprint,
                            contentDescription = "Fingerprint biometric scanner",
                            tint = JLWThemeMintAccent,
                            modifier = Modifier.size(24.dp)
                        )
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            text = "Fingerprint",
                            color = Color.White,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(36.dp))

            // Footer Section
            Text(
                text = "Internal Executive Tool • v4.2.0",
                color = JLWThemeSlateText,
                fontSize = 11.sp,
                textAlign = TextAlign.Center
            )
            
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 6.dp, bottom = 24.dp),
                horizontalArrangement = Arrangement.spacedBy(24.dp, Alignment.CenterHorizontally)
            ) {
                Text(
                    text = "Privacy Policy",
                    color = JLWThemeSlateText,
                    fontSize = 11.sp,
                    modifier = Modifier.clickable { }
                )
                Text(
                    text = "System Status",
                    color = JLWThemeSlateText,
                    fontSize = 11.sp,
                    modifier = Modifier.clickable { }
                )
            }
        }
    }
}
