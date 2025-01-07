import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4281231940),
      surfaceTint: Color(4281231940),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4289851841),
      onPrimaryContainer: Color(4278198542),
      secondary: Color(4287253093),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4294957541),
      onSecondaryContainer: Color(4281927457),
      tertiary: Color(4287580750),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4294957786),
      onTertiaryContainer: Color(4282058767),
      error: Color(4290386458),
      onError: Color(4294967295),
      errorContainer: Color(4294957782),
      onErrorContainer: Color(4282449922),
      surface: Color(4294376435),
      onSurface: Color(4279770392),
      onSurfaceVariant: Color(4282468173),
      outline: Color(4285692030),
      outlineVariant: Color(4290889678),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281086509),
      inversePrimary: Color(4288075174),
      primaryFixed: Color(4289851841),
      onPrimaryFixed: Color(4278198542),
      primaryFixedDim: Color(4288075174),
      onPrimaryFixedVariant: Color(4279390510),
      secondaryFixed: Color(4294957541),
      onSecondaryFixed: Color(4281927457),
      secondaryFixedDim: Color(4294947022),
      onSecondaryFixedVariant: Color(4285412173),
      tertiaryFixed: Color(4294957786),
      onTertiaryFixed: Color(4282058767),
      tertiaryFixedDim: Color(4294947765),
      onTertiaryFixedVariant: Color(4285739831),
      surfaceDim: Color(4292336596),
      surfaceBright: Color(4294376435),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4293981677),
      surfaceContainer: Color(4293652456),
      surfaceContainerHigh: Color(4293257954),
      surfaceContainerHighest: Color(4292863196),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4278996266),
      surfaceTint: Color(4281231940),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4282745176),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4285149001),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4288962683),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4285411123),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4289355619),
      onTertiaryContainer: Color(4294967295),
      error: Color(4287365129),
      onError: Color(4294967295),
      errorContainer: Color(4292490286),
      onErrorContainer: Color(4294967295),
      surface: Color(4294376435),
      onSurface: Color(4279770392),
      onSurfaceVariant: Color(4282205001),
      outline: Color(4284112998),
      outlineVariant: Color(4285889410),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281086509),
      inversePrimary: Color(4288075174),
      primaryFixed: Color(4282745176),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4281100097),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4288962683),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4287055971),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4289355619),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4287383371),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292336596),
      surfaceBright: Color(4294376435),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4293981677),
      surfaceContainer: Color(4293652456),
      surfaceContainerHigh: Color(4293257954),
      surfaceContainerHighest: Color(4292863196),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4278200594),
      surfaceTint: Color(4281231940),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4278996266),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4282519080),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4285149001),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4282650389),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4285411123),
      onTertiaryContainer: Color(4294967295),
      error: Color(4283301890),
      onError: Color(4294967295),
      errorContainer: Color(4287365129),
      onErrorContainer: Color(4294967295),
      surface: Color(4294376435),
      onSurface: Color(4278190080),
      onSurfaceVariant: Color(4280231210),
      outline: Color(4282205001),
      outlineVariant: Color(4282205001),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281086509),
      inversePrimary: Color(4290509770),
      primaryFixed: Color(4278996266),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4278203673),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4285149001),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4283373874),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4285411123),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4283570463),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292336596),
      surfaceBright: Color(4294376435),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4293981677),
      surfaceContainer: Color(4293652456),
      surfaceContainerHigh: Color(4293257954),
      surfaceContainerHighest: Color(4292863196),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4288075174),
      surfaceTint: Color(4288075174),
      onPrimary: Color(4278204700),
      primaryContainer: Color(4279390510),
      onPrimaryContainer: Color(4289851841),
      secondary: Color(4294947022),
      onSecondary: Color(4283637046),
      secondaryContainer: Color(4285412173),
      onSecondaryContainer: Color(4294957541),
      tertiary: Color(4294947765),
      onTertiary: Color(4283833634),
      tertiaryContainer: Color(4285739831),
      onTertiaryContainer: Color(4294957786),
      error: Color(4294948011),
      onError: Color(4285071365),
      errorContainer: Color(4287823882),
      onErrorContainer: Color(4294957782),
      surface: Color(4279244048),
      onSurface: Color(4292863196),
      onSurfaceVariant: Color(4290889678),
      outline: Color(4287336856),
      outlineVariant: Color(4282468173),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292863196),
      inversePrimary: Color(4281231940),
      primaryFixed: Color(4289851841),
      onPrimaryFixed: Color(4278198542),
      primaryFixedDim: Color(4288075174),
      onPrimaryFixedVariant: Color(4279390510),
      secondaryFixed: Color(4294957541),
      onSecondaryFixed: Color(4281927457),
      secondaryFixedDim: Color(4294947022),
      onSecondaryFixedVariant: Color(4285412173),
      tertiaryFixed: Color(4294957786),
      onTertiaryFixed: Color(4282058767),
      tertiaryFixedDim: Color(4294947765),
      onTertiaryFixedVariant: Color(4285739831),
      surfaceDim: Color(4279244048),
      surfaceBright: Color(4281678389),
      surfaceContainerLowest: Color(4278849291),
      surfaceContainerLow: Color(4279770392),
      surfaceContainer: Color(4280033564),
      surfaceContainerHigh: Color(4280691494),
      surfaceContainerHighest: Color(4281415217),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4288338346),
      surfaceTint: Color(4288075174),
      onPrimary: Color(4278197002),
      primaryContainer: Color(4284587635),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4294948561),
      onSecondary: Color(4281467419),
      secondaryContainer: Color(4291066776),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4294949307),
      onTertiary: Color(4281598730),
      tertiaryContainer: Color(4291525246),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294949553),
      onError: Color(4281794561),
      errorContainer: Color(4294923337),
      onErrorContainer: Color(4278190080),
      surface: Color(4279244048),
      onSurface: Color(4294442228),
      onSurfaceVariant: Color(4291218386),
      outline: Color(4288586666),
      outlineVariant: Color(4286481546),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292863196),
      inversePrimary: Color(4279521839),
      primaryFixed: Color(4289851841),
      onPrimaryFixed: Color(4278195463),
      primaryFixedDim: Color(4288075174),
      onPrimaryFixedVariant: Color(4278206240),
      secondaryFixed: Color(4294957541),
      onSecondaryFixed: Color(4281008150),
      secondaryFixedDim: Color(4294947022),
      onSecondaryFixedVariant: Color(4284097340),
      tertiaryFixed: Color(4294957786),
      onTertiaryFixed: Color(4281073670),
      tertiaryFixedDim: Color(4294947765),
      onTertiaryFixedVariant: Color(4284359464),
      surfaceDim: Color(4279244048),
      surfaceBright: Color(4281678389),
      surfaceContainerLowest: Color(4278849291),
      surfaceContainerLow: Color(4279770392),
      surfaceContainer: Color(4280033564),
      surfaceContainerHigh: Color(4280691494),
      surfaceContainerHighest: Color(4281415217),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4293918703),
      surfaceTint: Color(4288075174),
      onPrimary: Color(4278190080),
      primaryContainer: Color(4288338346),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4294965753),
      onSecondary: Color(4278190080),
      secondaryContainer: Color(4294948561),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4294965753),
      onTertiary: Color(4278190080),
      tertiaryContainer: Color(4294949307),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294965753),
      onError: Color(4278190080),
      errorContainer: Color(4294949553),
      onErrorContainer: Color(4278190080),
      surface: Color(4279244048),
      onSurface: Color(4294967295),
      onSurfaceVariant: Color(4294573055),
      outline: Color(4291218386),
      outlineVariant: Color(4291218386),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292863196),
      inversePrimary: Color(4278202904),
      primaryFixed: Color(4290180805),
      onPrimaryFixed: Color(4278190080),
      primaryFixedDim: Color(4288338346),
      onPrimaryFixedVariant: Color(4278197002),
      secondaryFixed: Color(4294959080),
      onSecondaryFixed: Color(4278190080),
      secondaryFixedDim: Color(4294948561),
      onSecondaryFixedVariant: Color(4281467419),
      tertiaryFixed: Color(4294959071),
      onTertiaryFixed: Color(4278190080),
      tertiaryFixedDim: Color(4294949307),
      onTertiaryFixedVariant: Color(4281598730),
      surfaceDim: Color(4279244048),
      surfaceBright: Color(4281678389),
      surfaceContainerLowest: Color(4278849291),
      surfaceContainerLow: Color(4279770392),
      surfaceContainer: Color(4280033564),
      surfaceContainerHigh: Color(4280691494),
      surfaceContainerHighest: Color(4281415217),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.background,
     canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
