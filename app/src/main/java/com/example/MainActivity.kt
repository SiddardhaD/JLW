package com.example

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.runtime.Composable
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.example.data.AppDatabase
import com.example.data.OrderRepository
import com.example.ui.screens.DashboardScreen
import com.example.ui.screens.LoginScreen
import com.example.ui.screens.OrderDetailsScreen
import com.example.ui.theme.MyApplicationTheme
import com.example.ui.viewmodel.ApprovalsViewModel
import com.example.ui.viewmodel.ApprovalsViewModelFactory

/**
 * Main Activity of JLW Approvals.
 * Replicates the full user journey of secure enterprise credentials, search, filter and validation.
 *
 * For Flutter Developers:
 * - This class acts similarly to Flutter's void main() + runApp(MaterialApp()) entry point
 * - AppNavigation matches MaterialApp with `onGenerateRoute` or [Navigator] routes
 * - Database initialization is similar to calling SharedPreferences/hive/floor init in main()
 */
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Initialize local Room SQL database and business repositories
        val database = AppDatabase.getDatabase(this)
        val repository = OrderRepository(database.orderDao, database.lineItemDao)
        val viewModelFactory = ApprovalsViewModelFactory(repository)
        
        // Get single shared ViewModel instance scoped to the Activity lifecycle
        val viewModel = ViewModelProvider(this, viewModelFactory)[ApprovalsViewModel::class.java]

        enableEdgeToEdge()
        setContent {
            MyApplicationTheme {
                AppNavigation(viewModel)
            }
        }
    }
}

/**
 * Controller mapping individual screen routes with arguments.
 * Equivalents in Flutter:
 * - navController.navigate() -> Navigator.pushNamed()
 * - popUpTo { inclusive } -> Navigator.pushNamedAndRemoveUntil()
 */
@Composable
fun AppNavigation(viewModel: ApprovalsViewModel) {
    val navController = rememberNavController()

    NavHost(
        navController = navController,
        startDestination = "login"
    ) {
        // Screen 1: Sign In Gateway
        composable("login") {
            LoginScreen(
                viewModel = viewModel,
                onLoginSuccess = {
                    navController.navigate("dashboard") {
                        popUpTo("login") { inclusive = true }
                    }
                }
            )
        }

        // Screen 2: Actionable Purchase Orders board
        composable("dashboard") {
            DashboardScreen(
                viewModel = viewModel,
                onOrderSelect = { orderId ->
                    navController.navigate("details/$orderId")
                },
                onLogout = {
                    viewModel.logout()
                    navController.navigate("login") {
                        popUpTo("dashboard") { inclusive = true }
                    }
                }
            )
        }

        // Screen 3: Details review with full audit log and line items
        composable(
            route = "details/{orderId}",
            arguments = listOf(navArgument("orderId") { type = NavType.StringType })
        ) { backStackEntry ->
            val orderId = backStackEntry.arguments?.getString("orderId") ?: ""
            OrderDetailsScreen(
                orderId = orderId,
                viewModel = viewModel,
                onBack = {
                    navController.popBackStack()
                }
            )
        }
    }
}
