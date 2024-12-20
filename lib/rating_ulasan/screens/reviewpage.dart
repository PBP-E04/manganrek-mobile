import 'package:flutter/material.dart';
import 'package:manganrek_mobile/rating_ulasan/models/review.dart';
import 'package:manganrek_mobile/widgets/left_drawer.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:manganrek_mobile/rating_ulasan/screens/reviewform.dart';

class ReviewEntryPage extends StatefulWidget {
  const ReviewEntryPage({super.key});

  @override
  State<ReviewEntryPage> createState() => _ReviewEntryPageState();
}

class _ReviewEntryPageState extends State<ReviewEntryPage> {
  late Future<List<Review>> futureReviews;
  late Future<List<Map<String, dynamic>>> usersFuture;
  late Map<int, String> usernameMap;
  List<dynamic>? rumahMakanList;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    futureReviews = fetchReviews(context.read<CookieRequest>());
    fetchRumahMakan(context.read<CookieRequest>());
    usersFuture = fetchUsers(context.read<CookieRequest>());
    usernameMap = {};
    prefetchUsernames();
  }

  Future<void> prefetchUsernames() async {
    try {
      final usersList = await fetchUsers(context.read<CookieRequest>());
      setState(() {
        usernameMap = {
          for (var user in usersList) user['id']: user['username']
        };
      });
    } catch (e) {
      print('Error prefetching usernames: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchUsers(CookieRequest request) async {
    try {
      final response =
          await request.get('http://127.0.0.1:8000/auth/get-users/');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  Future<List<Review>> fetchReviews(CookieRequest request) async {
    final response =
        await request.get('http://127.0.0.1:8000/review/show-json/');

    List<Review> listReviews = [];
    for (var d in response) {
      if (d != null) {
        listReviews.add(Review.fromJson(d));
      }
    }
    return listReviews;
  }

  Future<void> fetchRumahMakan(CookieRequest request) async {
    try {
      final response = await request
          .get('http://127.0.0.1:8000/restoran-makanan/json-rumahmakan/');
      if (response is List) {
        setState(() {
          rumahMakanList = response;
        });
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching RumahMakan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String? getRestaurantNameByPk(String pk) {
    if (rumahMakanList == null) return null;
    for (var restaurant in rumahMakanList!) {
      if (restaurant['pk'] == pk) {
        return restaurant['fields']['nama'];
      }
    }
    return null;
  }

  String? getUsernameFromMap(int id) {
    return usernameMap[id];
  }

  Future<List<Review>> filterReviews(String query) async {
    List<Review> allReviews = await fetchReviews(context.read<CookieRequest>());

    if (query.isEmpty) {
      return allReviews; // Return all reviews if query is empty
    }

    // Filter reviews based on query
    return allReviews.where((review) {
      final reviewNameLower = review.fields.reviewName.toLowerCase();
      final restaurantNameLower =
          getRestaurantNameByPk(review.fields.rumahMakan)?.toLowerCase() ?? '';
      final commentsLower = review.fields.comments.toLowerCase();

      final searchQueryLower = query.toLowerCase();

      return reviewNameLower.contains(searchQueryLower) ||
          restaurantNameLower.contains(searchQueryLower) ||
          commentsLower.contains(searchQueryLower);
    }).toList();
  }

  Widget _buildStarRating(int stars) {
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          index < stars ? Icons.star_rounded : Icons.star_outline_rounded,
          color: Colors.amber,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.rate_review_outlined,
                    size: 80, color: Theme.of(context).primaryColor),
                const SizedBox(height: 16),
                Text(
                  'No Reviews Yet',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Be the first to share your experience!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(
      Review review, bool isCurrentUser, CookieRequest request) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.green.shade50,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.fields.reviewName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.restaurant,
                                  size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  getRestaurantNameByPk(
                                          review.fields.rumahMakan) ??
                                      "Unknown Restaurant",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildStarRating(review.fields.stars),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    review.fields.comments,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dari: ${usernameMap[review.fields.user]} | Tanggal Kunjung: ${review.fields.visitDate.day}-${review.fields.visitDate.month}-${review.fields.visitDate.year}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    if (isCurrentUser)
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              // Edit functionality
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20),
                            color: Colors.red,
                            onPressed: () {
                              // Delete functionality with confirmation dialog
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Review?'),
                                  content: const Text(
                                      'Are you sure you want to delete this review?'),
                                  actions: [
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    TextButton(
                                      child: const Text('Delete',
                                          style: TextStyle(color: Colors.red)),
                                      onPressed: () {
                                        // Delete functionality
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Minta ulasannya, Rek!',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: theme.primaryColor,
        elevation: 0,
      ),
      drawer: const LeftDrawer(),
      floatingActionButton: request.loggedIn
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ReviewFormPage()),
                );
              },
              icon: const Icon(Icons.rate_review),
              label: const Text('Tulis Ulasan'),
              backgroundColor: theme.primaryColor,
            )
          : null,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari Ulasan...',
                    prefixIcon: Icon(Icons.search, color: theme.primaryColor),
                    suffixIcon: _isSearching
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _isSearching = false;
                                futureReviews =
                                    fetchReviews(context.read<CookieRequest>());
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _isSearching = value.isNotEmpty;
                      futureReviews = filterReviews(value);
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: futureReviews,
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text("Error: ${snapshot.error}",
                          style: const TextStyle(color: Colors.red)),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState();
                  } else {
                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (_, index) {
                        var review = snapshot.data![index];
                        bool isCurrentUser =
                            review.fields.user == request.jsonData['id'];
                        return _buildReviewCard(review, isCurrentUser, request);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
