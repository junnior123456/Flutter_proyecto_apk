# Guía de Estilos - PawFinder

## 📋 Archivo Principal: `app_styles.dart`

El archivo `lib/core/constants/app_styles.dart` contiene todos los estilos centralizados de la aplicación, organizados en diferentes categorías para fácil uso y mantenimiento.

## 🎨 Categorías de Estilos

### 1. **Estilos de Texto (TextStyle)**

#### Títulos
- `AppStyles.headingLarge` - Título principal (32px, bold, blanco)
- `AppStyles.headingMedium` - Título secundario (24px, bold)
- `AppStyles.headingSmall` - Título pequeño (20px, bold)

#### Subtítulos
- `AppStyles.subtitleLarge` - Subtítulo grande (18px, w600)
- `AppStyles.subtitleMedium` - Subtítulo mediano (16px, w500)
- `AppStyles.subtitleSmall` - Subtítulo pequeño (14px, w500)

#### Cuerpo de texto
- `AppStyles.bodyLarge` - Texto grande (16px, normal)
- `AppStyles.bodyMedium` - Texto mediano (14px, normal)
- `AppStyles.bodySmall` - Texto pequeño (12px, normal)

#### Botones
- `AppStyles.buttonLarge` - Texto de botón grande (16px, w600, blanco)
- `AppStyles.buttonMedium` - Texto de botón mediano (14px, w600, blanco)

#### Especiales
- `AppStyles.caption` - Texto descriptivo (12px, gris)
- `AppStyles.captionLight` - Texto descriptivo claro (12px, blanco70)
- `AppStyles.link` - Enlaces (14px, primario, subrayado)
- `AppStyles.linkWhite` - Enlaces blancos (14px, blanco, subrayado)

### 2. **Decoraciones (BoxDecoration)**

#### Gradientes
- `AppStyles.primaryGradient` - Gradiente principal (naranja a rojo oscuro)
- `AppStyles.welcomeGradient` - Gradiente de bienvenida (FF9800 a FF5722)
- `AppStyles.authGradient` - Gradiente de autenticación (vertical)

#### Contenedores
- `AppStyles.cardDecoration` - Tarjeta básica (blanco, sombra ligera)
- `AppStyles.elevatedCardDecoration` - Tarjeta elevada (sombra fuerte)
- `AppStyles.primaryContainer` - Contenedor primario (fondo con opacidad)
- `AppStyles.secondaryContainer` - Contenedor secundario
- `AppStyles.successContainer` - Contenedor de éxito (verde)
- `AppStyles.warningContainer` - Contenedor de advertencia (amarillo)
- `AppStyles.errorContainer` - Contenedor de error (rojo)

#### Formularios
- `AppStyles.textFieldDecoration` - Campo de texto básico

### 3. **Estilos de Botones (ButtonStyle)**

- `AppStyles.primaryButtonStyle` - Botón principal (naranja, elevación)
- `AppStyles.secondaryButtonStyle` - Botón secundario
- `AppStyles.outlineButtonStyle` - Botón con borde
- `AppStyles.textButtonStyle` - Botón de solo texto
- `AppStyles.dangerButtonStyle` - Botón de peligro (rojo)
- `AppStyles.successButtonStyle` - Botón de éxito (verde)

### 4. **Decoraciones de Entrada (InputDecoration)**

#### Método principal
```dart
AppStyles.textFieldInputDecoration({
  required String labelText,
  String? hintText,
  IconData? prefixIcon,
  Widget? suffixIcon,
  bool isError = false,
})
```

#### Método para autenticación
```dart
AppStyles.authInputDecoration({
  required String labelText,
  String? hintText,
  IconData? prefixIcon,
  Widget? suffixIcon,
  bool isError = false,
})
```

### 5. **Sombras (BoxShadow)**

- `AppStyles.lightShadow` - Sombra ligera
- `AppStyles.mediumShadow` - Sombra mediana
- `AppStyles.heavyShadow` - Sombra pesada

### 6. **Temas de Componentes**

- `AppStyles.appBarTheme` - Tema del AppBar
- `AppStyles.bottomNavTheme` - Tema del BottomNavigationBar
- `AppStyles.cardTheme` - Tema de las tarjetas
- `AppStyles.listTileTheme` - Tema de los ListTile
- `AppStyles.dialogTheme` - Tema de los diálogos

## 🛠️ Métodos Utilitarios

### `containerWithColor(Color color, {double opacity = 0.1})`
Crea un contenedor con color personalizado y opacidad.

### `customShadow({Color? color, double opacity = 0.1, double blurRadius = 5, Offset offset})`
Crea una sombra personalizada.

### `textWithColor(Color color, {double fontSize = 14, FontWeight fontWeight})`
Crea un estilo de texto con color personalizado.

## 💡 Ejemplos de Uso

### Texto con estilo
```dart
Text(
  'Título Principal',
  style: AppStyles.headingLarge,
)
```

### Botón con estilo
```dart
ElevatedButton(
  onPressed: () {},
  style: AppStyles.primaryButtonStyle,
  child: const Text('Mi Botón'),
)
```

### Contenedor con decoración
```dart
Container(
  decoration: AppStyles.cardDecoration,
  child: Text('Contenido'),
)
```

### Campo de texto
```dart
TextFormField(
  decoration: AppStyles.textFieldInputDecoration(
    labelText: 'Email',
    prefixIcon: Icons.email,
  ),
)
```

### Contenedor personalizado
```dart
Container(
  decoration: AppStyles.containerWithColor(Colors.blue, opacity: 0.2),
  child: Text('Contenido'),
)
```

## 📁 Estructura de Archivos

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_styles.dart          # ← ARCHIVO PRINCIPAL
│   │   ├── app_colors.dart          # Colores (usado por styles)
│   │   └── app_dimensions.dart      # Dimensiones (usado por styles)
│   ├── examples/
│   │   └── styles_example_page.dart # Ejemplos de uso
│   └── theme/
│       └── app_theme.dart           # Tema principal de la app
```

## ✨ Beneficios

1. **Consistencia**: Todos los estilos están centralizados
2. **Mantenibilidad**: Cambios en un solo lugar
3. **Escalabilidad**: Fácil añadir nuevos estilos
4. **Documentación**: Código autodocumentado
5. **Reutilización**: Componentes reutilizables
6. **Performance**: Estilos const cuando es posible

## 🔄 Migración

Para migrar estilos existentes:

1. Identifica el estilo usado (TextStyle, BoxDecoration, etc.)
2. Busca el equivalente en AppStyles
3. Si no existe, añádelo a app_styles.dart
4. Reemplaza el estilo inline con AppStyles.nombreDelEstilo
5. Elimina imports no utilizados

## 📝 Convenciones

- Usa `const` siempre que sea posible
- Nombres descriptivos y consistentes
- Agrupa estilos relacionados
- Documenta estilos complejos
- Mantén consistencia con el sistema de diseño