package com.example.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.data.OrderEntity
import com.example.data.OrderRepository
import com.example.data.LineItemEntity
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

/**
 * ViewModel for managing the state of JLW Approvals.
 * This handles UI view state updates similar to Dart's ChangeNotifier or Cubit in BLoC.
 */
class ApprovalsViewModel(private val repository: OrderRepository) : ViewModel() {

    // Authentication States
    private val _username = MutableStateFlow("")
    val username: StateFlow<String> = _username.asStateFlow()

    private val _password = MutableStateFlow("")
    val password: StateFlow<String> = _password.asStateFlow()

    private val _isAuthenticated = MutableStateFlow(false)
    val isAuthenticated: StateFlow<Boolean> = _isAuthenticated.asStateFlow()

    private val _loginError = MutableStateFlow<String?>(null)
    val loginError: StateFlow<String?> = _loginError.asStateFlow()

    // Dashboard States
    private val _searchQuery = MutableStateFlow("")
    val searchQuery: StateFlow<String> = _searchQuery.asStateFlow()

    private val _selectedFilter = MutableStateFlow("All") // "All", "High Value", "Today", "Pending"
    val selectedFilter: StateFlow<String> = _selectedFilter.asStateFlow()

    // Streams all orders from Room and seeds the database if empty on launch
    val ordersStream: StateFlow<List<OrderEntity>> = repository.allOrders
        .onEach {
            repository.seedDatabaseIfEmpty()
        }
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = emptyList()
        )

    // Reactive computation combining search text queries and filter pills
    val filteredOrders: StateFlow<List<OrderEntity>> = combine(
        ordersStream,
        _searchQuery,
        _selectedFilter
    ) { orders, query, filter ->
        orders.filter { order ->
            val matchesQuery = query.isEmpty() ||
                order.id.contains(query, ignoreCase = true) ||
                order.supplierName.contains(query, ignoreCase = true) ||
                order.originator.contains(query, ignoreCase = true)

            val matchesFilter = when (filter) {
                "High Value" -> order.priority == "HIGH VALUE" || order.orderAmount >= 50000000.0
                "Today" -> order.orderDate == "15-05-2024" // Matches our latest seeded date from screenshots
                "Pending" -> order.status == "Awaiting Approval"
                else -> true // "All"
            }

            matchesQuery && matchesFilter
        }
    }.stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = emptyList()
    )

    init {
        viewModelScope.launch {
            repository.seedDatabaseIfEmpty()
        }
    }

    // UI Input Event Actions
    fun onUsernameChange(value: String) {
        _username.value = value
        _loginError.value = null
    }

    fun onPasswordChange(value: String) {
        _password.value = value
        _loginError.value = null
    }

    fun login() {
        if (_username.value.trim().isEmpty()) {
            _loginError.value = "Username cannot be empty"
            return
        }
        if (_password.value.isEmpty()) {
            _loginError.value = "Password cannot be empty"
            return
        }
        _isAuthenticated.value = true
    }

    fun logout() {
        _isAuthenticated.value = false
        _username.value = ""
        _password.value = ""
        _selectedFilter.value = "All"
        _searchQuery.value = ""
    }

    fun onSearchQueryChange(value: String) {
        _searchQuery.value = value
    }

    fun onFilterChange(filter: String) {
        _selectedFilter.value = filter
    }

    // Business Logic Actions
    fun approveOrder(orderId: String) {
        viewModelScope.launch {
            repository.updateOrderStatus(orderId, "Approved")
        }
    }

    fun rejectOrder(orderId: String) {
        viewModelScope.launch {
            repository.updateOrderStatus(orderId, "Rejected")
        }
    }

    fun getLineItemsForOrder(orderId: String): Flow<List<LineItemEntity>> {
        return repository.getLineItemsForOrder(orderId)
    }

    fun getOrderById(orderId: String): Flow<OrderEntity?> {
        return repository.getOrderById(orderId)
    }
}

/**
 * Standard ViewModelProvider.Factory for dependency injection without heavy DI framework boilerplate.
 */
class ApprovalsViewModelFactory(private val repository: OrderRepository) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(ApprovalsViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return ApprovalsViewModel(repository) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
