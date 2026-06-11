package com.example.data

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.withContext

/**
 * Repository for managing Purchase Orders and their line items.
 * Acts as the single source of truth (similar to Repository / Service classes in Dart/Flutter).
 */
class OrderRepository(
    private val orderDao: OrderDao,
    private val lineItemDao: LineItemDao
) {
    // Flows that stream the database content reactively
    val allOrders: Flow<List<OrderEntity>> = orderDao.getAllOrders()

    fun getOrderById(orderId: String): Flow<OrderEntity?> = orderDao.getOrderById(orderId)

    fun getLineItemsForOrder(orderId: String): Flow<List<LineItemEntity>> =
        lineItemDao.getLineItemsForOrder(orderId)

    suspend fun updateOrderStatus(orderId: String, status: String) {
        withContext(Dispatchers.IO) {
            orderDao.updateOrderStatus(orderId, status)
        }
    }

    /**
     * Seed the database on first run so the screens are styled and populated
     * matching the exact cases in the mockup images (orders: 2323135, 2323136, 2323137)
     */
    suspend fun seedDatabaseIfEmpty() {
        withContext(Dispatchers.IO) {
            if (orderDao.getOrdersCount() == 0) {
                // Main Purchase Orders
                val seedOrders = listOf(
                    OrderEntity(
                        id = "2323135",
                        originator = "Anubhav",
                        responsible = "Nitya",
                        project = "M30",
                        orderType = "OP",
                        orderDate = "12-05-2024",
                        supplierName = "James O'Malley Enterprise",
                        orderAmount = 20002202.0,
                        currency = "AED",
                        priority = "URGENT",
                        status = "Awaiting Approval",
                        coNumber = "00200",
                        projectIdFull = "M30-INFRA-2024"
                    ),
                    OrderEntity(
                        id = "2323136",
                        originator = "Hiten",
                        responsible = "Nitya",
                        project = "M30",
                        orderType = "OP",
                        orderDate = "14-05-2024",
                        supplierName = "Global Logistics Ltd.",
                        orderAmount = 20105400.0,
                        currency = "AED",
                        priority = "ROUTINE",
                        status = "Awaiting Approval",
                        coNumber = "00325",
                        projectIdFull = "M30-LOGISTICS-2024"
                    ),
                    OrderEntity(
                        id = "2323137",
                        originator = "Shiddartl",
                        responsible = "Nitya",
                        project = "M30",
                        orderType = "OP",
                        orderDate = "15-05-2024",
                        supplierName = "James O'Malley Enterprise",
                        orderAmount = 284000000.0,
                        currency = "AED",
                        priority = "HIGH VALUE",
                        status = "Awaiting Approval",
                        coNumber = "00401",
                        projectIdFull = "M30-MEGA-INFRA"
                    )
                )
                orderDao.insertOrders(seedOrders)

                // High fidelity line items details mapping matching mockup screens
                val seedLineItems = listOf(
                    // Order #2323135 (Total equivalent matches)
                    LineItemEntity(
                        orderId = "2323135",
                        lineNumber = 1,
                        itemCode = "210-998-A",
                        requestedDate = "10-06-2026",
                        description = "Precision Grade Structural Steel - Grade 50 / Type 2 Reinforcement Rods",
                        quantity = 31.0,
                        unit = "KG",
                        unitCost = 10.0,
                        extendedCost = 310.0
                    ),
                    LineItemEntity(
                        orderId = "2323135",
                        lineNumber = 2,
                        itemCode = "440-X12",
                        requestedDate = "10-06-2026",
                        description = "Standard Steel Connectors & Anchor Bolts (Zinc Coated)",
                        quantity = 15.0,
                        unit = "UNIT",
                        unitCost = 8.0,
                        extendedCost = 120.0
                    ),
                    LineItemEntity(
                        orderId = "2323135",
                        lineNumber = 3,
                        itemCode = "EXC-H77",
                        requestedDate = "10-06-2026",
                        description = "Heavy Infrastructure Mechanical Excavation Core Assemblies - Base Contractor Installment",
                        quantity = 1.0,
                        unit = "LOT",
                        unitCost = 20001772.0,
                        extendedCost = 20001772.0 // Sum will make 20,002,202.0 AED perfectly!
                    ),

                    // Order #2323136 Line Items
                    LineItemEntity(
                        orderId = "2323136",
                        lineNumber = 1,
                        itemCode = "610-LOG-B",
                        requestedDate = "10-06-2026",
                        description = "International Air Freight Cargo Shippings (High Priority Transport)",
                        quantity = 2.0,
                        unit = "SHIPMENT",
                        unitCost = 10052700.0,
                        extendedCost = 20105400.0
                    ),

                    // Order #2323137 Line Items
                    LineItemEntity(
                        orderId = "2323137",
                        lineNumber = 1,
                        itemCode = "999-STRUCT-M",
                        requestedDate = "10-06-2026",
                        description = "Heavy Duty Foundation Concrete Pouring & Sub-Level Tunnel Reinforcements",
                        quantity = 1.0,
                        unit = "LOT",
                        unitCost = 284000000.0,
                        extendedCost = 284000000.0
                    )
                )
                lineItemDao.insertLineItems(seedLineItems)
            }
        }
    }
}
