import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final MapController _mapController = MapController();

  // Tọa độ cho địa chỉ 474 Dương Tự Minh, Quán Triều, Thành phố Thái Nguyên
  static const LatLng _aptechLocation = LatLng(21.5805, 105.8468);

  // Thông tin địa chỉ
  static const String _address = "474 Dương Tự Minh, Quán Triều, Thành phố Thái Nguyên, Thái Nguyên";
  static const String _businessName = "APTECH MOBILE";
  static const String _phone = "0123 456 789";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vị trí của chúng tôi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 2,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Thông tin địa chỉ
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B5E20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.store,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _businessName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Trung tâm đào tạo công nghệ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.location_on, _address),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.access_time, 'Mở cửa: 8:00 - 21:00 (Thứ 2 - Chủ nhật)'),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.phone, _phone),
              ],
            ),
          ),

          // OpenStreetMap - Fixed configuration
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _aptechLocation, // Fixed: use initialCenter instead of center
                  initialZoom: 16.0, // Fixed: use initialZoom instead of zoom
                  maxZoom: 18.0,
                  minZoom: 10.0,
                ),
                children: [
                  // Tile layer (bản đồ nền)
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.aptech.mobile_app',
                    maxNativeZoom: 19,
                  ),

                  // Marker layer - Fixed configuration
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _aptechLocation,
                        width: 60,
                        height: 60,
                        child: GestureDetector( // Fixed: use child instead of builder
                          onTap: () => _showLocationInfo(),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF1B5E20),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.store,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Nút hành động
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openDirections,
                    icon: const Icon(Icons.directions, color: Colors.white),
                    label: const Text(
                      'Chỉ đường',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _makePhoneCall,
                  icon: const Icon(Icons.phone, color: Color(0xFF1B5E20)),
                  label: const Text(
                    'Gọi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF1B5E20), width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "zoom_in",
            mini: true,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1B5E20),
            onPressed: () {
              // Fixed: use camera methods instead of deprecated move
              _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1);
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "zoom_out",
            mini: true,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1B5E20),
            onPressed: () {
              // Fixed: use camera methods instead of deprecated move
              _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1);
            },
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "my_location",
            mini: true,
            backgroundColor: const Color(0xFF1B5E20),
            foregroundColor: Colors.white,
            onPressed: () {
              _mapController.move(_aptechLocation, 16.0);
            },
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: const Color(0xFF1B5E20),
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  void _showLocationInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5E20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.store,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(_businessName),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _address,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Điện thoại: $_phone',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Giờ mở cửa: 8:00 - 21:00',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _openDirections();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
              ),
              child: const Text('Chỉ đường', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openDirections() async {
    final lat = _aptechLocation.latitude;
    final lng = _aptechLocation.longitude;

    // Thử mở Google Maps trước
    final googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';

    try {
      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(
          Uri.parse(googleMapsUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback sang OpenStreetMap
        final osmUrl = 'https://www.openstreetmap.org/directions?to=$lat%2C$lng';
        await launchUrl(
          Uri.parse(osmUrl),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể mở ứng dụng bản đồ'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _makePhoneCall() async {
    final phoneUrl = 'tel:$_phone';

    try {
      if (await canLaunchUrl(Uri.parse(phoneUrl))) {
        await launchUrl(Uri.parse(phoneUrl));
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể thực hiện cuộc gọi'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi khi gọi điện thoại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}