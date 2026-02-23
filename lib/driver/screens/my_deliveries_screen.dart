import 'package:bestseeds/driver/models/driver_booking_model.dart';
import 'package:bestseeds/driver/repository/driver_auth_repository.dart';
import 'package:bestseeds/driver/services/driver_storage_service.dart';
import 'package:bestseeds/widgets/route_visualization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyDeliveriesScreen extends StatefulWidget {
  const MyDeliveriesScreen({super.key});

  @override
  State<MyDeliveriesScreen> createState() => _MyDeliveriesScreenState();
}

class _MyDeliveriesScreenState extends State<MyDeliveriesScreen> {
  final DriverAuthRepository _repo = DriverAuthRepository();
  final DriverStorageService _storage = DriverStorageService();

  bool _isLoading = true;
  String? _errorMessage;
  List<DriverRoute> _routes = [];

  @override
  void initState() {
    super.initState();
    _fetchDeliveries();
  }

  Future<void> _fetchDeliveries() async {
    final token = _storage.getToken();
    if (token == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Session expired. Please login again.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _repo.getBookings(token);
      // Filter only routes where all bookings are status 5 (delivered) or 6 (cancelled)
      final pastRoutes = response.routes.where((route) {
        return route.bookings.every((b) => b.status == 5 || b.status == 6);
      }).toList();

      setState(() {
        _routes = pastRoutes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load deliveries. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Deliveries',
          style: TextStyle(
            fontSize: width * 0.05,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: _buildBody(width, height),
    );
  }

  Widget _buildBody(double width, double height) {
    if (_isLoading) {
      return _buildShimmerList(width, height);
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(width * 0.06),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: width * 0.15, color: Colors.grey.shade400),
              SizedBox(height: height * 0.02),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: width * 0.04, color: Colors.grey.shade600),
              ),
              SizedBox(height: height * 0.02),
              ElevatedButton(
                onPressed: _fetchDeliveries,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0077C8),
                ),
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (_routes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping_outlined, size: width * 0.2, color: Colors.grey.shade300),
            SizedBox(height: height * 0.02),
            Text(
              'No deliveries yet',
              style: TextStyle(
                fontSize: width * 0.045,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
            SizedBox(height: height * 0.01),
            Text(
              'Your completed and cancelled\ndeliveries will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: width * 0.038,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchDeliveries,
      color: const Color(0xFF0077C8),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(width * 0.04),
        itemCount: _routes.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: height * 0.02),
            child: _buildDeliveryCard(width, height, _routes[index]),
          );
        },
      ),
    );
  }

  Widget _buildDeliveryCard(double width, double height, DriverRoute route) {
    final dateFormatted = route.packingDate != null
        ? DateFormat('dd MMM yyyy').format(route.packingDate!)
        : 'N/A';

    final isDelivered = route.isCompleted;
    final statusLabel = isDelivered ? 'Delivered' : 'Cancelled';
    final statusColor = isDelivered ? const Color(0xFF4CAF50) : const Color(0xFFE53935);
    final statusBgColor = isDelivered
        ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
        : const Color(0xFFE53935).withValues(alpha: 0.1);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Date Header with Status
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.04,
              vertical: height * 0.015,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormatted,
                  style: TextStyle(
                    fontSize: width * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.03,
                    vertical: height * 0.005,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: width * 0.032,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// Card Content
          Padding(
            padding: EdgeInsets.all(width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Booking IDs Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'ID: ${route.bookingIdsString}',
                        style: TextStyle(
                          fontSize: width * 0.038,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${route.totalDrops} Drops',
                      style: TextStyle(
                        fontSize: width * 0.032,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.012),

                /// Hatchery Name
                Text(
                  route.hatcheryName,
                  style: TextStyle(
                    fontSize: width * 0.042,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                /// Category
                if (route.categoryName.isNotEmpty)
                  Text(
                    route.categoryName,
                    style: TextStyle(
                      fontSize: width * 0.035,
                      color: Colors.grey.shade600,
                    ),
                  ),
                SizedBox(height: height * 0.015),

                /// Route Visualization
                buildRouteVisualization(width, height, route),

                SizedBox(height: height * 0.015),

                /// Pieces Info
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: width * 0.045,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: width * 0.02),
                    Text(
                      '${route.totalPieces} Pieces',
                      style: TextStyle(
                        fontSize: width * 0.038,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList(double width, double height) {
    return ListView.builder(
      padding: EdgeInsets.all(width * 0.04),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: height * 0.02),
          child: Container(
            height: height * 0.22,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Shimmer header
                Container(
                  height: height * 0.05,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(width * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: width * 0.5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: height * 0.012),
                      Container(
                        height: 16,
                        width: width * 0.6,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: height * 0.012),
                      Container(
                        height: 12,
                        width: width * 0.35,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: height * 0.015),
                      Container(
                        height: 14,
                        width: width * 0.4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
