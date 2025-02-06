class Constants {
  // App Information
  static const String appName = 'WordPress App';
  static const String appVersion = '1.0.0';
  
  // WordPress Configuration
  static const String wordpressUrl = 'https://wehorseracing.com';
  static const String apiEndpoint = '$wordpressUrl/wp-json/wp/v2';
  static const String authEndpoint = '$wordpressUrl/wp-json/jwt-auth/v1';
  
  // API Endpoints
  static const String postsEndpoint = '$apiEndpoint/posts';
  static const String categoriesEndpoint = '$apiEndpoint/categories';
  static const String commentsEndpoint = '$apiEndpoint/comments';
  static const String usersEndpoint = '$apiEndpoint/users';
  static const String loginEndpoint = '$authEndpoint/token';
  static const String validateTokenEndpoint = '$authEndpoint/token/validate';
  static const String registerEndpoint = '$wordpressUrl/wp-json/wp/v2/users/register';
  
  // Default Images
  static const String defaultFeaturedImage = '$wordpressUrl/wp-content/uploads/2023/default-image.jpg';
  static const String defaultAvatarImage = '$wordpressUrl/wp-content/uploads/2023/default-avatar.jpg';
  
  // API Fields
  static const String embedParam = '_embed=true';
  
  // Category IDs
  static const int featuredId = 1;
  static const int page2CategoryId = 2;
  static const String page2CategoryName = 'Latest News';
  
  // API Parameters
  static const int defaultPostsPerPage = 10;
  static const int searchPostsPerPage = 20;
  
  // Cache Configuration
  static const Duration cacheDuration = Duration(hours: 1);
  static const Duration tokenExpiration = Duration(days: 7);
  static const int maxCacheItems = 100;
  
  // Font Configuration
  static const String fontFamily = 'Tajawal';
  static const Map<String, String> fontWeights = {
    'regular': 'Regular',
    'medium': 'Medium',
    'bold': 'Bold',
    'extraBold': 'ExtraBold',
    'extraLight': 'ExtraLight',
  };

  // Text Styles
  static const Map<String, Map<String, dynamic>> textStyles = {
    'title': {
      'fontSize': 24.0,
      'fontWeight': 'bold',
      'letterSpacing': -0.5,
    },
    'subtitle': {
      'fontSize': 18.0,
      'fontWeight': 'medium',
      'letterSpacing': -0.2,
    },
    'body': {
      'fontSize': 16.0,
      'fontWeight': 'regular',
      'letterSpacing': 0.0,
    },
    'caption': {
      'fontSize': 14.0,
      'fontWeight': 'regular',
      'letterSpacing': 0.2,
    },
  };
  
  // Custom Categories
  static const List<Map<String, dynamic>> customCategories = [
    {'id': 1, 'name': 'Technology', 'icon': 'assets/boxed/technology.png'},
    {'id': 2, 'name': 'Fashion', 'icon': 'assets/boxed/fashion.png'},
    {'id': 3, 'name': 'Health', 'icon': 'assets/boxed/health.png'},
    {'id': 4, 'name': 'Lifestyle', 'icon': 'assets/boxed/lifestyle.png'},
    {'id': 5, 'name': 'Music', 'icon': 'assets/boxed/music.png'},
    {'id': 6, 'name': 'Photography', 'icon': 'assets/boxed/photography.png'},
    {'id': 7, 'name': 'Recipes', 'icon': 'assets/boxed/recipies.png'},
    {'id': 8, 'name': 'Sport', 'icon': 'assets/boxed/sport.png'},
    {'id': 9, 'name': 'Travel', 'icon': 'assets/boxed/travel.png'},
    {'id': 10, 'name': 'World', 'icon': 'assets/boxed/world.png'},
  ];
  
  // Asset Paths
  static const String noInternetImage = 'assets/no-internet.png';
  static const String playButtonImage = 'assets/play-button.png';
  static const String headerBackground = 'wp-content/uploads/2023/08/header-bg.jpg';
  static const String appIcon = 'assets/icon.png';
  
  // UI Constants
  static const double appBarHeight = 56.0;
  static const double cardBorderRadius = 12.0;
  static const double gridSpacing = 16.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  // Error Messages
  static const String noInternetError = 'No Internet connection';
  static const String generalError = 'Something went wrong';
  static const String noPostsFound = 'No articles found';
  static const String loadingError = 'Error loading content';
  static const String invalidCredentials = 'Invalid username or password';
  static const String registrationError = 'Registration failed';
  static const String usernameTaken = 'Username is already taken';
  static const String emailTaken = 'Email is already registered';
  static const String weakPassword = 'Password is too weak';
  
  // Local Storage Keys
  static const String bookmarksKey = 'bookmarked_posts';
  static const String themeKey = 'app_theme';
  static const String userKey = 'user_data';
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  
  // Social Share
  static const Map<String, String> shareIcons = {
    'facebook': 'assets/more/facebook.png',
    'twitter': 'assets/more/twitter.png',
    'whatsapp': 'assets/more/whatsapp.png',
  };
  
  // Date Formats
  static const String defaultDateFormat = 'MMM dd, yyyy';
  static const String shortDateFormat = 'MM/dd/yy';
  static const String timeFormat = 'HH:mm';
  
  // Navigation
  static const String homeRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String profileRoute = '/profile';
  static const String categoryRoute = '/category';
  static const String articleRoute = '/article';
  static const String searchRoute = '/search';
  static const String bookmarksRoute = '/bookmarks';

  // API Query Helper
  static String getPostsEndpoint({
    int? page,
    int? perPage,
    int? categoryId,
    String? searchQuery,
    bool embed = true,
  }) {
    final params = <String, String>{
      if (page != null) 'page': page.toString(),
      if (perPage != null) 'per_page': perPage.toString(),
      if (categoryId != null) 'categories': categoryId.toString(),
      if (searchQuery != null) 'search': searchQuery,
      if (embed) '_embed': 'true',
    };

    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '$postsEndpoint${queryString.isNotEmpty ? '?$queryString' : ''}';
  }
}
