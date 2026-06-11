package com.example.ui.screens

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.OrderEntity
import com.example.ui.theme.*
import com.example.ui.viewmodel.ApprovalsViewModel
import java.text.NumberFormat
import java.util.Locale

/**
 * Screen 2: Dashboard showing "Orders Awaiting Approval".
 * Matches mockup Screen 2 exactly.
 *
 * For Flutter Developers:
 * - This screen represents [Scaffold] with [AppBar], [Column], [TextField], and a [ListView.builder]
 * - NavigationBar matches the [BottomNavigationBar] widget
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DashboardScreen(
    viewModel: ApprovalsViewModel,
    onOrderSelect: (orderId: String) -> Unit,
    onLogout: () -> Unit
) {
    val searchQuery by viewModel.searchQuery.collectAsState()
    val selectedFilter by viewModel.selectedFilter.collectAsState()
    val orders by viewModel.filteredOrders.collectAsState()

    var activeTab by remember { mutableStateOf("Approvals") } // "Approvals", "Review", "Account"

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = "Orders Awaiting Approval",
                        color = Color.White,
                        fontSize = 19.sp,
                        fontWeight = FontWeight.Bold
                    )
                },
                navigationIcon = {
                    IconButton(onClick = { /* Hamburger menu action */ }) {
                        Icon(
                            imageVector = Icons.Default.Menu,
                            contentDescription = "Hamburger Navigation Menu",
                            tint = JLWThemeMintAccent
                        )
                    }
                },
                actions = {
                    IconButton(onClick = onLogout) {
                        Icon(
                            imageVector = Icons.Default.Close,
                            contentDescription = "Logout Application Drawer",
                            tint = JLWThemeMintAccent
                        )
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = JLWThemeDarkBg,
                    titleContentColor = Color.White
                )
            )
        },
        bottomBar = {
            // M3 Bottom Navigation Bar
            NavigationBar(
                containerColor = JLWThemeDarkBg,
                tonalElevation = 8.dp,
                modifier = Modifier.windowInsetsPadding(WindowInsets.navigationBars)
            ) {
                // Approvals Tab
                NavigationBarItem(
                    selected = activeTab == "Approvals",
                    onClick = { activeTab = "Approvals" },
                    icon = {
                        Icon(
                            imageVector = Icons.Default.FactCheck,
                            contentDescription = "Approvals Tab Icon",
                            tint = if (activeTab == "Approvals") JLWThemeDarkText else JLWThemeSlateText
                        )
                    },
                    label = {
                        Text(
                            "Approvals",
                            color = if (activeTab == "Approvals") JLWThemeMintAccent else JLWThemeSlateText,
                            fontWeight = if (activeTab == "Approvals") FontWeight.Bold else FontWeight.Normal,
                            fontSize = 11.sp
                        )
                    },
                    colors = NavigationBarItemDefaults.colors(
                        indicatorColor = JLWThemeMintAccent
                    )
                )

                // Review Tab (Placeholder screen)
                NavigationBarItem(
                    selected = activeTab == "Review",
                    onClick = { activeTab = "Review" },
                    icon = {
                        Icon(
                            imageVector = Icons.Default.PendingActions,
                            contentDescription = "Review Tab Icon",
                            tint = if (activeTab == "Review") JLWThemeDarkText else JLWThemeSlateText
                        )
                    },
                    label = {
                        Text(
                            "Review",
                            color = if (activeTab == "Review") JLWThemeMintAccent else JLWThemeSlateText,
                            fontWeight = if (activeTab == "Review") FontWeight.Bold else FontWeight.Normal,
                            fontSize = 11.sp
                        )
                    },
                    colors = NavigationBarItemDefaults.colors(
                        indicatorColor = JLWThemeMintAccent
                    )
                )

                // Account Tab (Settings/Logout)
                NavigationBarItem(
                    selected = activeTab == "Account",
                    onClick = { activeTab = "Account" },
                    icon = {
                        Icon(
                            imageVector = Icons.Default.Person,
                            contentDescription = "Account Profile Icon",
                            tint = if (activeTab == "Account") JLWThemeDarkText else JLWThemeSlateText
                        )
                    },
                    label = {
                        Text(
                            "Account",
                            color = if (activeTab == "Account") JLWThemeMintAccent else JLWThemeSlateText,
                            fontWeight = if (activeTab == "Account") FontWeight.Bold else FontWeight.Normal,
                            fontSize = 11.sp
                        )
                    },
                    colors = NavigationBarItemDefaults.colors(
                        indicatorColor = JLWThemeMintAccent
                    )
                )
            }
        },
        containerColor = JLWThemeDarkBg,
        modifier = Modifier.fillMaxSize()
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(horizontal = 16.dp)
        ) {
            
            if (activeTab == "Approvals") {
                // Approver Status Block (Top Info panel)
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(top = 8.dp, bottom = 12.dp)
                        .clip(RoundedCornerShape(8.dp))
                        .border(BorderStroke(1.dp, JLWBorderColor), RoundedCornerShape(8.dp))
                        .background(JLWThemeCardBg)
                        .padding(14.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    // Left Column: Approver ID
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = "APPROVER ID",
                            color = JLWThemeSlateText,
                            fontSize = 10.sp,
                            fontWeight = FontWeight.Bold,
                            letterSpacing = 0.5.sp
                        )
                        Text(
                            text = "1234567",
                            color = JLWThemeMintAccent,
                            fontSize = 15.sp,
                            fontWeight = FontWeight.Bold,
                            modifier = Modifier.padding(top = 2.dp)
                        )
                    }

                    // Middle vertical divider
                    Box(
                        modifier = Modifier
                            .height(34.dp)
                            .width(1.dp)
                            .background(JLWBorderColor)
                    )

                    Spacer(modifier = Modifier.width(16.dp))

                    // Right Column: Project
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = "PROJECT",
                            color = JLWThemeSlateText,
                            fontSize = 10.sp,
                            fontWeight = FontWeight.Bold,
                            letterSpacing = 0.5.sp
                        )
                        Text(
                            text = "M30",
                            color = JLWThemeMintAccent,
                            fontSize = 15.sp,
                            fontWeight = FontWeight.Bold,
                            modifier = Modifier.padding(top = 2.dp)
                        )
                    }
                }

                // Search Bar Field
                OutlinedTextField(
                    value = searchQuery,
                    onValueChange = { viewModel.onSearchQueryChange(it) },
                    placeholder = {
                        Text(
                            text = "Search by Order No., Supplier...",
                            color = JLWThemeSlateText.copy(alpha = 0.7f),
                            fontSize = 14.sp
                        )
                    },
                    leadingIcon = {
                        Icon(
                            imageVector = Icons.Default.Search,
                            contentDescription = "Search Purchase Orders Icon",
                            tint = JLWThemeSlateText
                        )
                    },
                    trailingIcon = if (searchQuery.isNotEmpty()) {
                        {
                            IconButton(onClick = { viewModel.onSearchQueryChange("") }) {
                                Icon(
                                    imageVector = Icons.Default.Close,
                                    contentDescription = "Clear search filter",
                                    tint = JLWThemeSlateText
                                )
                            }
                        }
                    } else null,
                    singleLine = true,
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = JLWBorderColor,
                        unfocusedBorderColor = JLWBorderColor,
                        focusedContainerColor = JLWThemeInputBg,
                        unfocusedContainerColor = JLWThemeInputBg,
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White
                    ),
                    shape = RoundedCornerShape(8.dp),
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(bottom = 14.dp)
                        .testTag("dashboard_search")
                )

                // Category Tabs / Filter Pills Row
                val filters = listOf("All", "High Value", "Today", "Pending")
                LazyRow(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(bottom = 16.dp),
                    contentPadding = PaddingValues(end = 4.dp)
                ) {
                    items(filters) { item ->
                        val isSelected = selectedFilter == item
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(20.dp))
                                .background(if (isSelected) JLWThemeMintAccent else JLWStatusRoutine)
                                .clickable { viewModel.onFilterChange(item) }
                                .padding(horizontal = 16.dp, vertical = 8.dp)
                        ) {
                            Text(
                                text = item,
                                color = if (isSelected) JLWThemeDarkText else Color.White,
                                fontSize = 13.sp,
                                fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium
                            )
                        }
                    }
                }

                // Orders List
                if (orders.isEmpty()) {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .weight(1f),
                        contentAlignment = Alignment.Center
                    ) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Icon(
                                imageVector = Icons.Default.FactCheck,
                                contentDescription = "Empty order queue list",
                                tint = JLWThemeSlateText,
                                modifier = Modifier.size(54.dp)
                            )
                            Spacer(modifier = Modifier.height(12.dp))
                            Text(
                                text = "No Orders Match Your Query",
                                color = JLWThemeSlateText,
                                fontSize = 15.sp,
                                fontWeight = FontWeight.Bold
                            )
                            Text(
                                text = "Try modifying your search or select 'All'",
                                color = JLWThemeSlateText.copy(alpha = 0.8f),
                                fontSize = 13.sp,
                                textAlign = TextAlign.Center,
                                modifier = Modifier.padding(start = 24.dp, top = 4.dp, end = 24.dp)
                            )
                        }
                    }
                } else {
                    LazyColumn(
                        verticalArrangement = Arrangement.spacedBy(14.dp),
                        modifier = Modifier
                            .weight(1f)
                            .testTag("orders_list"),
                        contentPadding = PaddingValues(bottom = 24.dp)
                    ) {
                        items(orders, key = { it.id }) { order ->
                            OrderCardItem(
                                order = order,
                                onCardClick = { onOrderSelect(order.id) },
                                onApprove = { viewModel.approveOrder(order.id) },
                                onReject = { viewModel.rejectOrder(order.id) }
                            )
                        }
                    }
                }
            } else if (activeTab == "Review") {
                // Secondary Drawer/Section: Review
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally, modifier = Modifier.padding(24.dp)) {
                        Icon(
                            imageVector = Icons.Default.PendingActions,
                            contentDescription = "Review historical submissions",
                            tint = JLWThemeMintAccent,
                            modifier = Modifier.size(64.dp)
                        )
                        Spacer(modifier = Modifier.height(16.dp))
                        Text(
                            "Audit Logs & Historical Review",
                            color = Color.White,
                            fontSize = 18.sp,
                            fontWeight = FontWeight.Bold
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            "This panel enables enterprise users to audit previously signed off procurement vouchers and invoices.",
                            color = JLWThemeSlateText,
                            fontSize = 13.sp,
                            textAlign = TextAlign.Center
                        )
                    }
                }
            } else {
                // Account Settings Screen
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally, modifier = Modifier.padding(24.dp)) {
                        Icon(
                            imageVector = Icons.Default.AccountCircle,
                            contentDescription = "Profile management panel",
                            tint = JLWThemeMintAccent,
                            modifier = Modifier.size(72.dp)
                        )
                        Spacer(modifier = Modifier.height(16.dp))
                        Text("Active Identity: Executive 1234567", color = Color.White, fontSize = 18.sp, fontWeight = FontWeight.Bold)
                        Text("Role: Project M30 Senior Approver", color = JLWThemeSlateText, fontSize = 14.sp)
                        
                        Spacer(modifier = Modifier.height(32.dp))
                        
                        Button(
                            onClick = onLogout,
                            colors = ButtonDefaults.buttonColors(containerColor = JLWStatusHighValue),
                            shape = RoundedCornerShape(8.dp),
                            modifier = Modifier.fillMaxWidth(0.7f)
                        ) {
                            Text("Logout Identity", fontWeight = FontWeight.Bold, color = Color.White)
                        }
                    }
                }
            }
        }
    }
}

/**
 * Individual Order card row.
 * Includes precise alignment, priorities, tags, borders and dynamic actions.
 */
@Composable
fun OrderCardItem(
    order: OrderEntity,
    onCardClick: () -> Unit,
    onApprove: () -> Unit,
    onReject: () -> Unit
) {
    // Standard currency formatting
    val formattedAmount = remember(order.orderAmount) {
        val format = NumberFormat.getNumberInstance(Locale.US)
        format.format(order.orderAmount)
    }

    val isHighValue = order.priority == "HIGH VALUE"
    val isAwaiting = order.status == "Awaiting Approval"

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(8.dp))
            .background(JLWThemeCardBg)
            .border(
                BorderStroke(
                    1.dp,
                    if (isHighValue && isAwaiting) JLWStatusHighValue else JLWBorderColor
                ),
                RoundedCornerShape(8.dp)
            )
            .clickable { onCardClick() }
            .testTag("order_item_card_${order.id}")
    ) {
        Column(modifier = Modifier.fillMaxWidth()) {
            
            // CARD HEADER: Order # and badge
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 14.dp, vertical = 10.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // If warning is needed (e.g. #2323137 High Value), show warning icon
                if (isHighValue) {
                    Icon(
                        imageVector = Icons.Default.Warning,
                        contentDescription = "High Value critical risk warning icon",
                        tint = JLWStatusWarningBorder,
                        modifier = Modifier
                            .padding(end = 8.dp)
                            .size(16.dp)
                    )
                }

                Text(
                    text = "ORDER #${order.id}",
                    color = Color.White,
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.weight(1f)
                )

                // Priority category tag
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(4.dp))
                        .background(
                            when (order.priority) {
                                "URGENT" -> JLWThemeInputBg
                                "HIGH VALUE" -> JLWStatusHighValue
                                else -> JLWStatusRoutine
                            }
                        )
                        .border(
                            BorderStroke(
                                1.dp,
                                when (order.priority) {
                                    "URGENT" -> JLWThemeMintAccent.copy(alpha = 0.5f)
                                    else -> Color.Transparent
                                }
                            ), RoundedCornerShape(4.dp)
                        )
                        .padding(horizontal = 8.dp, vertical = 4.dp)
                ) {
                    Text(
                        text = order.priority,
                        color = when (order.priority) {
                            "URGENT" -> JLWThemeMintAccent
                            else -> Color.White
                        },
                        fontSize = 9.sp,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 0.5.sp
                    )
                }
            }

            // Divider
            HorizontalDivider(color = JLWBorderColor)

            // CARD GRID DATA ROW (Using nested custom styled grids)
            Column(modifier = Modifier.padding(14.dp)) {
                // Row 1: Originator and Responsible Party
                Row(modifier = Modifier.fillMaxWidth().padding(bottom = 10.dp)) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text("Originator", color = JLWThemeSlateText, fontSize = 11.sp)
                        Text(order.originator, color = Color.White, fontSize = 13.sp, fontWeight = FontWeight.Bold, modifier = Modifier.padding(top = 1.dp))
                    }
                    Column(modifier = Modifier.weight(1f)) {
                        Text("Responsible", color = JLWThemeSlateText, fontSize = 11.sp)
                        Text(order.responsible, color = Color.White, fontSize = 13.sp, fontWeight = FontWeight.Bold, modifier = Modifier.padding(top = 1.dp))
                    }
                }

                // Row 2: Order Ty and Order Date
                Row(modifier = Modifier.fillMaxWidth().padding(bottom = 10.dp)) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text("Order Ty", color = JLWThemeSlateText, fontSize = 11.sp)
                        Text(order.orderType, color = Color.White, fontSize = 13.sp, fontWeight = FontWeight.Bold, modifier = Modifier.padding(top = 1.dp))
                    }
                    Column(modifier = Modifier.weight(1f)) {
                        Text("Order Date", color = JLWThemeSlateText, fontSize = 11.sp)
                        Text(order.orderDate, color = Color.White, fontSize = 13.sp, fontWeight = FontWeight.Bold, modifier = Modifier.padding(top = 1.dp))
                    }
                }

                // Row 3: Supplier Name
                Column(modifier = Modifier.fillMaxWidth().padding(bottom = 12.dp)) {
                    Text("Supplier Name", color = JLWThemeSlateText, fontSize = 11.sp)
                    Text(
                        text = order.supplierName,
                        color = Color.White,
                        fontSize = 13.sp,
                        fontWeight = FontWeight.Bold,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        modifier = Modifier.padding(top = 1.dp)
                    )
                }

                // Divider
                HorizontalDivider(color = JLWBorderColor, modifier = Modifier.padding(bottom = 12.dp))

                // Bottom Action & Amount Section
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    // Left Column: Order Amount
                    Column {
                        Text("Order Amount", color = JLWThemeSlateText, fontSize = 11.sp)
                        Row(modifier = Modifier.padding(top = 2.dp), verticalAlignment = Alignment.Bottom) {
                            Text(
                                text = formattedAmount,
                                color = if (order.status == "Rejected") JLWThemeSlateText else JLWThemeMintAccent,
                                fontSize = 19.sp,
                                fontWeight = FontWeight.Bold
                            )
                            Spacer(modifier = Modifier.width(4.dp))
                            Text(
                                text = order.currency,
                                color = if (order.status == "Rejected") JLWThemeSlateText else JLWThemeMintAccent,
                                fontSize = 11.sp,
                                fontWeight = FontWeight.Bold,
                                modifier = Modifier.padding(bottom = 2.dp)
                            )
                        }
                    }

                    // Right Column: Dynamic Action Buttons depending on Approval status
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        when (order.status) {
                            "Awaiting Approval" -> {
                                if (isHighValue) {
                                    // High Value mockup shows BOTH Reject and Approve buttons inline!
                                    Button(
                                        onClick = { onReject() },
                                        colors = ButtonDefaults.buttonColors(
                                            containerColor = JLWButtonReject,
                                            contentColor = Color.White
                                        ),
                                        shape = RoundedCornerShape(4.dp),
                                        border = BorderStroke(1.dp, JLWBorderColor),
                                        contentPadding = PaddingValues(horizontal = 14.dp, vertical = 6.dp),
                                        modifier = Modifier.height(36.dp)
                                    ) {
                                        Text("REJECT", fontSize = 11.sp, fontWeight = FontWeight.Bold)
                                    }
                                }

                                Button(
                                    onClick = { onApprove() },
                                    colors = ButtonDefaults.buttonColors(
                                        containerColor = JLWThemeMintAccent,
                                        contentColor = JLWThemeDarkText
                                    ),
                                    shape = RoundedCornerShape(4.dp),
                                    contentPadding = PaddingValues(horizontal = 14.dp, vertical = 6.dp),
                                    modifier = Modifier.height(36.dp)
                                ) {
                                    Text("APPROVE", fontSize = 11.sp, fontWeight = FontWeight.Bold)
                                }
                            }
                            "Approved" -> {
                                Row(verticalAlignment = Alignment.CenterVertically) {
                                    Icon(
                                        imageVector = Icons.Default.Check,
                                        contentDescription = "Approved order checklist icon",
                                        tint = JLWThemeMintAccent,
                                        modifier = Modifier.size(16.dp)
                                    )
                                    Spacer(modifier = Modifier.width(4.dp))
                                    Text("APPROVED", color = JLWThemeMintAccent, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                                }
                            }
                            "Rejected" -> {
                                Row(verticalAlignment = Alignment.CenterVertically) {
                                    Icon(
                                        imageVector = Icons.Default.Close,
                                        contentDescription = "Rejected order mark icon",
                                        tint = JLWStatusHighValue,
                                        modifier = Modifier.size(16.dp)
                                    )
                                    Spacer(modifier = Modifier.width(4.dp))
                                    Text("REJECTED", color = JLWStatusHighValue, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
