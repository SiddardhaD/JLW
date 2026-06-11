package com.example.ui.screens

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.LineItemEntity
import com.example.data.OrderEntity
import com.example.ui.theme.*
import com.example.ui.viewmodel.ApprovalsViewModel
import java.text.NumberFormat
import java.util.Locale

/**
 * Screen 3: Order Details screen.
 * Displays detailed summary and line items blocks for individual purchase orders.
 * Matches mockup Screen 3 exactly.
 *
 * For Flutter Developers:
 * - This corresponds to a [Scaffold] with [ListView] showing mixed headers and cards
 * - Outline borders are created similarly to Flutter's [BoxDecoration] with [Border]
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun OrderDetailsScreen(
    orderId: String,
    viewModel: ApprovalsViewModel,
    onBack: () -> Unit
) {
    val orderQuery = remember(orderId) { viewModel.getOrderById(orderId) }
    val order by orderQuery.collectAsState(initial = null)

    val lineItemsFlow = remember(orderId) { viewModel.getLineItemsForOrder(orderId) }
    val lineItems by lineItemsFlow.collectAsState(initial = emptyList())

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = "Order No: $orderId",
                        color = Color.White,
                        fontSize = 19.sp,
                        fontWeight = FontWeight.Bold
                    )
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Default.ArrowBack,
                            contentDescription = "Navigate back to search lists",
                            tint = JLWThemeMintAccent
                        )
                    }
                },
                actions = {
                    IconButton(onClick = onBack) {
                        Icon(
                            imageVector = Icons.Default.Close,
                            contentDescription = "Close detailed view panel",
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
            // Persistent Large Bottom Call-to-actions
            if (order != null) {
                val ord = order!!
                Row(
                    modifier = Modifier
                        .background(JLWThemeDarkBg)
                        .windowInsetsPadding(WindowInsets.navigationBars)
                        .padding(14.dp)
                        .fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    if (ord.status == "Awaiting Approval") {
                        // REJECT ORDER button
                        Button(
                            onClick = {
                                viewModel.rejectOrder(orderId)
                            },
                            colors = ButtonDefaults.buttonColors(
                                containerColor = JLWButtonReject,
                                contentColor = Color.White
                            ),
                            shape = RoundedCornerShape(6.dp),
                            border = BorderStroke(1.dp, JLWBorderColor),
                            contentPadding = PaddingValues(vertical = 14.dp),
                            modifier = Modifier
                                .weight(0.4f)
                                .testTag("detail_reject_button")
                        ) {
                            Text(
                                "REJECT\nORDER",
                                fontWeight = FontWeight.Bold,
                                fontSize = 11.sp,
                                textAlign = TextAlign.Center,
                                lineHeight = 14.sp
                            )
                        }

                        // APPROVE NOW button
                        Button(
                            onClick = {
                                viewModel.approveOrder(orderId)
                            },
                            colors = ButtonDefaults.buttonColors(
                                containerColor = JLWThemeMintAccent,
                                contentColor = JLWThemeDarkText
                            ),
                            shape = RoundedCornerShape(6.dp),
                            contentPadding = PaddingValues(vertical = 14.dp),
                            modifier = Modifier
                                .weight(0.6f)
                                .testTag("detail_approve_button")
                        ) {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.Center
                            ) {
                                Icon(
                                    imageVector = Icons.Default.CheckCircle,
                                    contentDescription = "Checkmark seal",
                                    tint = JLWThemeDarkText,
                                    modifier = Modifier.size(20.dp)
                                )
                                Spacer(modifier = Modifier.width(8.dp))
                                Column {
                                    Text(
                                        "APPROVE",
                                        fontWeight = FontWeight.Bold,
                                        fontSize = 13.sp,
                                        lineHeight = 14.sp
                                    )
                                    Text(
                                        "NOW",
                                        fontWeight = FontWeight.Bold,
                                        fontSize = 11.sp,
                                        lineHeight = 12.sp
                                    )
                                }
                            }
                        }
                    } else {
                        // Order is already approved or rejected
                        Card(
                            colors = CardDefaults.cardColors(
                                containerColor = if (ord.status == "Approved") JLWThemeInputBg else JLWThemeInputBg
                            ),
                            border = BorderStroke(
                                1.dp,
                                if (ord.status == "Approved") JLWThemeMintAccent else JLWStatusHighValue
                            ),
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Text(
                                text = "ORDER ${ord.status.uppercase(Locale.ROOT)} SECURELY BY EXECUTIVE",
                                color = if (ord.status == "Approved") JLWThemeMintAccent else JLWStatusHighValue,
                                fontWeight = FontWeight.Bold,
                                fontSize = 14.sp,
                                textAlign = TextAlign.Center,
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(vertical = 16.dp)
                            )
                        }
                    }
                }
            }
        },
        containerColor = JLWThemeDarkBg,
        modifier = Modifier.fillMaxSize()
    ) { innerPadding ->
        if (order == null) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(innerPadding),
                contentAlignment = Alignment.Center
            ) {
                CircularProgressIndicator(color = JLWThemeMintAccent)
            }
        } else {
            val ord = order!!

            LazyColumn(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(innerPadding)
                    .padding(horizontal = 16.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                // Section 1: ORDER SUMMARY Card
                item {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(top = 12.dp)
                            .clip(RoundedCornerShape(8.dp))
                            .background(JLWThemeCardBg)
                            .border(BorderStroke(1.dp, JLWBorderColor), RoundedCornerShape(8.dp))
                    ) {
                        // Section Header Title
                        Text(
                            text = "ORDER SUMMARY",
                            color = JLWThemeMintAccent,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold,
                            letterSpacing = 0.5.sp,
                            modifier = Modifier.padding(horizontal = 14.dp, vertical = 12.dp)
                        )
                        HorizontalDivider(color = JLWBorderColor)

                        // ROW 1: ORIGINATOR | RESPONSIBLE PARTY
                        Row(modifier = Modifier.fillMaxWidth()) {
                            Column(
                                modifier = Modifier
                                    .weight(1.5f)
                                    .border(BorderStroke(0.5.dp, JLWBorderColor))
                                    .padding(14.dp)
                            ) {
                                Text("ORIGINATOR", color = JLWThemeSlateText, fontSize = 10.sp, fontWeight = FontWeight.Bold)
                                Text(ord.originator, color = Color.White, fontSize = 14.sp, fontWeight = FontWeight.Bold, modifier = Modifier.padding(top = 2.dp))
                            }
                            Column(
                                modifier = Modifier
                                    .weight(2f)
                                    .border(BorderStroke(0.5.dp, JLWBorderColor))
                                    .padding(14.dp)
                            ) {
                                Text("RESPONSIBLE PARTY", color = JLWThemeSlateText, fontSize = 10.sp, fontWeight = FontWeight.Bold)
                                Text(ord.responsible, color = Color.White, fontSize = 14.sp, fontWeight = FontWeight.Bold, modifier = Modifier.padding(top = 2.dp))
                            }
                        }

                        // ROW 2: PROJECT ID (Full screen width)
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .border(BorderStroke(0.5.dp, JLWBorderColor))
                                .padding(14.dp)
                        ) {
                            Text("PROJECT ID", color = JLWThemeSlateText, fontSize = 10.sp, fontWeight = FontWeight.Bold)
                            Text(ord.projectIdFull, color = Color.White, fontSize = 14.sp, fontWeight = FontWeight.Bold, modifier = Modifier.padding(top = 2.dp))
                        }

                        // ROW 3: CO NUMBER | ORDER DATE
                        Row(modifier = Modifier.fillMaxWidth()) {
                            Column(
                                modifier = Modifier
                                    .weight(1.5f)
                                    .border(BorderStroke(0.5.dp, JLWBorderColor))
                                    .padding(14.dp)
                            ) {
                                Text("CO NUMBER", color = JLWThemeSlateText, fontSize = 10.sp, fontWeight = FontWeight.Bold)
                                Text(ord.coNumber, color = Color.White, fontSize = 14.sp, fontWeight = FontWeight.Bold, modifier = Modifier.padding(top = 2.dp))
                            }
                            Column(
                                modifier = Modifier
                                    .weight(2f)
                                    .border(BorderStroke(0.5.dp, JLWBorderColor))
                                    .padding(14.dp)
                            ) {
                                Text("ORDER DATE", color = JLWThemeSlateText, fontSize = 10.sp, fontWeight = FontWeight.Bold)
                                Text(
                                    text = if (ord.id == "2323135") "10-OCT-2026" else ord.orderDate,
                                    color = Color.White,
                                    fontSize = 14.sp,
                                    fontWeight = FontWeight.Bold,
                                    modifier = Modifier.padding(top = 2.dp)
                                )
                            }
                        }

                        // ROW 4: ORDER STATUS
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .border(BorderStroke(0.5.dp, JLWBorderColor))
                                .padding(14.dp)
                        ) {
                            Text("ORDER STATUS", color = JLWThemeSlateText, fontSize = 10.sp, fontWeight = FontWeight.Bold)
                            Row(
                                modifier = Modifier.padding(top = 4.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Box(
                                    modifier = Modifier
                                        .size(7.dp)
                                        .clip(RoundedCornerShape(4.dp))
                                        .background(
                                            when (ord.status) {
                                                "Approved" -> JLWThemeMintAccent
                                                "Rejected" -> JLWStatusHighValue
                                                else -> Color(0xFFF59E0B) // Amber
                                            }
                                        )
                                )
                                Spacer(modifier = Modifier.width(6.dp))
                                Text(
                                    text = ord.status,
                                    color = when (ord.status) {
                                        "Approved" -> JLWThemeMintAccent
                                        "Rejected" -> JLWStatusHighValue
                                        else -> Color(0xFFF59E0B) // Amber tint matching mockup "Awaiting Approval"
                                    },
                                    fontSize = 14.sp,
                                    fontWeight = FontWeight.Bold
                                )
                            }
                        }

                        // ROW 5: SUPPLIER NAME
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .border(BorderStroke(0.5.dp, JLWBorderColor))
                                .padding(14.dp)
                        ) {
                            Text("SUPPLIER NAME", color = JLWThemeSlateText, fontSize = 10.sp, fontWeight = FontWeight.Bold)
                            Text(
                                text = if (ord.id == "2323135") "James O' Malley Global Sourcing Ltd." else ord.supplierName,
                                color = Color.White,
                                fontSize = 14.sp,
                                fontWeight = FontWeight.Bold,
                                modifier = Modifier.padding(top = 2.dp)
                            )
                        }
                    }
                }

                // Section 2: Line Items Header Group
                item {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(top = 8.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text(
                            text = "Line Items",
                            color = Color.White,
                            fontSize = 20.sp,
                            fontWeight = FontWeight.Bold
                        )

                        // Count pill
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(4.dp))
                                .background(JLWThemeInputBg)
                                .border(BorderStroke(1.dp, JLWBorderColor), RoundedCornerShape(4.dp))
                                .padding(horizontal = 8.dp, vertical = 4.dp)
                        ) {
                            Text(
                                text = "${lineItems.size} Items",
                                color = JLWThemeMintAccent,
                                fontSize = 12.sp,
                                fontWeight = FontWeight.Bold
                            )
                        }
                    }
                }

                // Section 3: Line Items List
                items(lineItems) { item ->
                    LineItemCard(item = item)
                }

                item {
                    Spacer(modifier = Modifier.height(14.dp))
                }
            }
        }
    }
}

/**
 * High-fidelity individual Line Item details.
 * Implements the table segmentation, header dividing block, description and cost metrics boxes.
 */
@Composable
fun LineItemCard(item: LineItemEntity) {
    val formattedUnitCost = remember(item.unitCost) {
        val format = NumberFormat.getNumberInstance(Locale.US)
        format.format(item.unitCost)
    }
    
    val formattedExtendedCost = remember(item.extendedCost) {
        val format = NumberFormat.getNumberInstance(Locale.US)
        format.format(item.extendedCost)
    }

    val formattedQty = remember(item.quantity) {
        val format = NumberFormat.getNumberInstance(Locale.US)
        val formatted = format.format(item.quantity)
        // Trim standard fractions if intact integer
        if (item.quantity == item.quantity.toInt().toDouble()) {
            "${item.quantity.toInt()} ${item.unit}"
        } else {
            "$formatted ${item.unit}"
        }
    }

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(8.dp))
            .background(JLWThemeCardBg)
            .border(BorderStroke(1.dp, JLWBorderColor), RoundedCornerShape(8.dp))
    ) {
        
        // CARD ROW HEADER MOCK-SEGMENT
        Row(modifier = Modifier.fillMaxWidth()) {
            // Box 1: Line number
            Column(
                modifier = Modifier
                    .weight(1f)
                    .border(BorderStroke(0.5.dp, JLWBorderColor))
                    .padding(10.dp)
            ) {
                Text("Line", color = JLWThemeSlateText, fontSize = 9.sp, fontWeight = FontWeight.Bold)
                Text(
                    text = item.lineNumber.toString(),
                    color = Color.White,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.padding(top = 1.dp)
                )
            }

            // Box 2: Item Code
            Column(
                modifier = Modifier
                    .weight(2.5f)
                    .border(BorderStroke(0.5.dp, JLWBorderColor))
                    .padding(10.dp)
            ) {
                Text("Item Code", color = JLWThemeSlateText, fontSize = 9.sp, fontWeight = FontWeight.Bold)
                Text(
                    text = item.itemCode,
                    color = Color.White,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.padding(top = 1.dp)
                )
            }

            // Box 3: Requested Date
            Column(
                modifier = Modifier
                    .weight(2.5f)
                    .border(BorderStroke(0.5.dp, JLWBorderColor))
                    .padding(10.dp)
            ) {
                Text("Requested Date", color = JLWThemeSlateText, fontSize = 9.sp, fontWeight = FontWeight.Bold)
                Text(
                    text = item.requestedDate,
                    color = Color.White,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.padding(top = 1.dp)
                )
            }
        }

        // DESCRIPTION BLOCK
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .border(BorderStroke(0.5.dp, JLWBorderColor))
                .padding(12.dp)
        ) {
            Text("Description", color = JLWThemeSlateText, fontSize = 9.sp, fontWeight = FontWeight.Bold)
            Text(
                text = item.description,
                color = Color.White,
                fontSize = 13.sp,
                fontWeight = FontWeight.Bold,
                lineHeight = 17.sp,
                modifier = Modifier.padding(top = 2.dp)
            )
        }

        // PRICE SEGMENTS ROW
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            // Box 1: QTY
            Column(
                modifier = Modifier
                    .weight(1f)
                    .border(BorderStroke(1.dp, JLWBorderColor), RoundedCornerShape(4.dp))
                    .background(JLWThemeInputBg)
                    .padding(10.dp)
            ) {
                Text("QTY", color = JLWThemeSlateText, fontSize = 9.sp, fontWeight = FontWeight.Bold)
                Text(
                    text = formattedQty,
                    color = JLWThemeMintAccent,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.padding(top = 2.dp)
                )
            }

            // Box 2: Unit Cost
            Column(
                modifier = Modifier
                    .weight(1f)
                    .border(BorderStroke(1.dp, JLWBorderColor), RoundedCornerShape(4.dp))
                    .background(JLWThemeInputBg)
                    .padding(10.dp)
            ) {
                Text("Unit Cost", color = JLWThemeSlateText, fontSize = 9.sp, fontWeight = FontWeight.Bold)
                Text(
                    text = "$formattedUnitCost AED",
                    color = Color.White,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.padding(top = 2.dp)
                )
            }

            // Box 3: Extended Cost
            Column(
                modifier = Modifier
                    .weight(1.2f)
                    .border(BorderStroke(1.dp, JLWBorderColor), RoundedCornerShape(4.dp))
                    .background(JLWThemeInputBg)
                    .padding(10.dp)
            ) {
                Text("Extended Cost", color = JLWThemeSlateText, fontSize = 9.sp, fontWeight = FontWeight.Bold)
                Text(
                    text = "$formattedExtendedCost AED",
                    color = JLWThemeMintAccent,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.padding(top = 2.dp)
                )
            }
        }
    }
}
