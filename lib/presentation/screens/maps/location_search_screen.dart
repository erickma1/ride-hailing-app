import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import '../../../data/models/location_model.dart';

class LocationSearchScreen extends StatefulWidget {
  final String title;
  
  const LocationSearchScreen({Key? key, required this.title}) : super(key: key);

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  late TextEditingController _searchController;
  List<LocationModel> searchResults = [];
  bool isSearching = false;

  // Popular locations in Ghana
  final popularLocations = [
    LocationModel(
      address: 'Accra Central',
      latitude: 5.5520,
      longitude: -0.2029,
      placeName: 'Accra Central',
      placeType: 'City Center',
    ),
    LocationModel(
      address: 'Osu',
      latitude: 5.5753,
      longitude: -0.1693,
      placeName: 'Osu',
      placeType: 'District',
    ),
    LocationModel(
      address: 'Tema',
      latitude: 5.6140,
      longitude: -0.0119,
      placeName: 'Tema',
      placeType: 'City',
    ),
    LocationModel(
      address: 'Kumasi',
      latitude: 6.6753,
      longitude: -1.6207,
      placeName: 'Kumasi',
      placeType: 'City',
    ),
    LocationModel(
      address: 'Cape Coast',
      latitude: 5.1033,
      longitude: -1.2455,
      placeName: 'Cape Coast',
      placeType: 'City',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchLocations(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    setState(() {
      isSearching = true;
    });

    try {
      final locations = await locationFromAddress(query);
      
      setState(() {
        searchResults = locations
            .map((location) => LocationModel(
              address: query,
              latitude: location.latitude,
              longitude: location.longitude,
            ))
            .toList();
      });
    } catch (e) {
      // Show popular locations as fallback
      setState(() {
        searchResults = popularLocations
            .where((loc) =>
                loc.placeName!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    } finally {
      setState(() {
        isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _searchLocations,
              decoration: InputDecoration(
                hintText: 'Search location...',
                prefixIcon: Icon(Icons.location_on_outlined),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            searchResults = [];
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: isSearching
                ? Center(child: CircularProgressIndicator())
                : searchResults.isEmpty
                    ? _buildPopularLocations()
                    : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularLocations() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Text(
          'Popular Locations',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12),
        ...popularLocations.map((location) {
          return ListTile(
            leading: Icon(Icons.location_on_outlined),
            title: Text(location.placeName ?? location.address),
            subtitle: Text(location.placeType ?? ''),
            onTap: () => Get.back(result: location),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final location = searchResults[index];
        return ListTile(
          leading: Icon(Icons.location_on_outlined),
          title: Text(location.address),
          onTap: () => Get.back(result: location),
        );
      },
    );
  }
}
