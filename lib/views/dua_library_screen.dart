import 'package:blessing/core/widgets/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DuaCategory {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isFavorite;

  DuaCategory({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isFavorite = false,
  });
}

class DuaLibraryScreen extends StatefulWidget {
  const DuaLibraryScreen({super.key});

  @override
  State<DuaLibraryScreen> createState() => _DuaLibraryScreenState();
}

class _DuaLibraryScreenState extends State<DuaLibraryScreen> {
  final Color primaryGreen = const Color(0xFF00FF66);
  final TextEditingController _searchController = TextEditingController();

  final List<DuaCategory> _categories = [
    DuaCategory(
      title: "Favorites",
      subtitle: "Your collection",
      icon: Icons.favorite_rounded,
      isFavorite: true,
    ),
    DuaCategory(
      title: "Morning & Evening",
      subtitle: "Explore",
      icon: Icons.wb_sunny_rounded,
    ),
    DuaCategory(
      title: "Home & Family",
      subtitle: "Explore",
      icon: Icons.home_rounded,
    ),
    DuaCategory(
      title: "Food & Drink",
      subtitle: "Explore",
      icon: Icons.restaurant_rounded,
    ),
    DuaCategory(
      title: "Joy & Distress",
      subtitle: "Explore",
      icon: Icons.sentiment_satisfied_alt_rounded,
    ),
    DuaCategory(
      title: "Nature",
      subtitle: "Explore",
      icon: Icons.bookmark_rounded,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Center(
          child: CustomCircleIconButton(
            icon: Icons.keyboard_arrow_left_rounded,
            onTap: () => Navigator.pop(context),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Duas',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.tune_rounded, color: Colors.white70, size: 20),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildSearchBar(),
              const SizedBox(height: 20),
              _buildDuaOfTheDayCard(),
              const SizedBox(height: 24),
              _buildCategoryHeader(),
              const SizedBox(height: 16),
              _buildCategoryGrid(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF131924),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          icon: Icon(Icons.search_rounded, color: primaryGreen, size: 22),
          hintText: "Search categories...",
          hintStyle: GoogleFonts.outfit(color: Colors.white38, fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDuaOfTheDayCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF131924),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Opacity(
                opacity: 0.15,
                child: Image.network(
                  'https://images.unsplash.com/photo-1544947950-fa07a98d237f',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "Dua of the Day",
                      style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_border_rounded, color: Colors.white, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "Morning Adhkar",
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "\"O Allah, by Your leave we have reached the morning...\"",
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    "READ NOW",
                    style: GoogleFonts.outfit(
                      color: primaryGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, color: primaryGreen, size: 14),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Categories",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "View All",
          style: GoogleFonts.outfit(
            color: primaryGreen,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.15,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF131924),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: category.isFavorite
                  ? primaryGreen
                  : Colors.white.withValues(alpha: 0.08),
              width: category.isFavorite ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                category.icon,
                color: primaryGreen,
                size: 24,
              ),
              const Spacer(),
              Text(
                category.title,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                category.subtitle,
                style: GoogleFonts.outfit(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
