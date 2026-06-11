package com.example.data

import androidx.room.*
import kotlinx.coroutines.flow.Flow

/**
 * Data Access Object for Order entities.
 */
@Dao
interface OrderDao {
    @Query("SELECT * FROM orders ORDER BY id ASC")
    fun getAllOrders(): Flow<List<OrderEntity>>

    @Query("SELECT * FROM orders WHERE id = :orderId LIMIT 1")
    fun getOrderById(orderId: String): Flow<OrderEntity?>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertOrders(orders: List<OrderEntity>)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertOrder(order: OrderEntity)

    @Update
    suspend fun updateOrder(order: OrderEntity)

    @Query("UPDATE orders SET status = :status WHERE id = :orderId")
    suspend fun updateOrderStatus(orderId: String, status: String)

    @Query("SELECT COUNT(*) FROM orders")
    suspend fun getOrdersCount(): Int
}

/**
 * Data Access Object for Purchase Order Line Items.
 */
@Dao
interface LineItemDao {
    @Query("SELECT * FROM line_items WHERE orderId = :orderId ORDER BY lineNumber ASC")
    fun getLineItemsForOrder(orderId: String): Flow<List<LineItemEntity>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertLineItems(lineItems: List<LineItemEntity>)
}
