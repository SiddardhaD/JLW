package com.example.data

import androidx.room.Entity
import androidx.room.PrimaryKey

/**
 * Represents a Purchase Order in the JLW system.
 * This is equivalent to database tables in Flutter's sqflite or floor frameworks.
 */
@Entity(tableName = "orders")
data class OrderEntity(
    @PrimaryKey val id: String, // e.g. "2323135"
    val originator: String,
    val responsible: String,
    val project: String,
    val orderType: String,
    val orderDate: String,
    val supplierName: String,
    val orderAmount: Double,
    val currency: String, // AED
    val priority: String, // "URGENT", "ROUTINE", "HIGH VALUE"
    val status: String,   // "Awaiting Approval", "Approved", "Rejected"
    val coNumber: String,
    val projectIdFull: String
)

/**
 * Represents a specific Line Item in a Purchase Order.
 */
@Entity(tableName = "line_items")
data class LineItemEntity(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    val orderId: String, // References [OrderEntity.id]
    val lineNumber: Int,
    val itemCode: String,
    val requestedDate: String,
    val description: String,
    val quantity: Double,
    val unit: String, // KG, UNIT, etc.
    val unitCost: Double,
    val extendedCost: Double
)
