# Pymes ERP Móvil

![Versión](https://img.shields.io/badge/versi%C3%B3n-1.0.0-black)
![Flutter](https://img.shields.io/badge/Flutter-Dart%203.13-02569B)
![Plataforma](https://img.shields.io/badge/plataforma-Android-3DDC84)

Aplicación móvil de **Pymes ERP**, un ERP ligero con Punto de Venta para pequeños negocios de Cartagena de Indias: restaurantes, cafeterías, tiendas de barrio, papelerías y ferreterías. Se conecta a la misma API que la versión web, de modo que la información del negocio es una sola.

La prioridad es vender: la contabilidad se genera sola a partir de la operación diaria.

## Descarga

El APK de la última versión está en la sección de [Releases](https://github.com/jsebasvgg7/Pymes-Mobile/releases/latest).

1. Descarga el archivo `.apk` desde Assets.
2. Ábrelo en tu teléfono Android.
3. Si el sistema lo pide, permite la instalación desde orígenes desconocidos.

## Funcionalidades

| Módulo | Descripción |
|---|---|
| Acceso | Inicio de sesión, registro de cuenta, bienvenida de primera vez, sesión recordada y guardia de sesión |
| Dashboard | Resumen del negocio, gráfica de flujo de caja (semanal por defecto) y movimientos recientes |
| Inventario | Listado de productos con filtros y el mismo criterio de stock bajo que la versión web |
| Punto de venta | Catálogo por categorías, carrito con cantidad editable, factura y nueva venta |
| Caja | Abrir, cerrar y reabrir caja, movimientos con filtros y creación de nuevas cajas |

Además: navegación inferior, estado de carga con la marca de Pymes, avatar generado por usuario y tipografía Inter.

## Tecnologías

| Área | Herramienta |
|---|---|
| Framework | Flutter (Dart `^3.13.7`) |
| Navegación | `go_router` |
| Estado | `provider` |
| Red | `dio` |
| Almacenamiento seguro | `flutter_secure_storage` |
| Iconos | `hugeicons` |
| Compartir | `share_plus` |

## Arquitectura

El código se organiza por funcionalidad, cada una con su capa de datos (modelos y repositorio) y su capa de presentación (controlador y pantallas).

```
lib/
├── main.dart
├── app/            Tema, rutas, navegación y estructura general
├── core/           Configuración, red, almacenamiento, formato y widgets compartidos
└── features/
    ├── auth/
    ├── dashboard/
    ├── inventario/
    ├── pos/
    └── caja/
```

## Configuración

La aplicación usa por defecto la API de producción. Para apuntar a otro servidor, define `API_URL` al compilar o ejecutar:

```bash
flutter run --dart-define=API_URL=TU_URL_DE_LA_API
```

## Desarrollo

Requisitos: Flutter con Dart `^3.13.7` y un dispositivo o emulador Android.

```bash
git clone https://github.com/jsebasvgg7/Pymes-Mobile.git
cd Pymes-Mobile
flutter pub get
flutter run
```

Análisis y pruebas:

```bash
flutter analyze
flutter test
```

## Compilar el APK

```bash
flutter build apk --release
```

El archivo queda en `build/app/outputs/flutter-apk/app-release.apk`.

## Proyectos relacionados

- [Pymes ERP (web y API)](https://github.com/jsebasvgg7/pymes-erp)

## Equipo

John Sebastian Vega Gonzalez, Bryan Andres Tuñon Bermudez, Mahicol Hurtado Jimenez y Rowin Otalora Cano.

Docente: Laura Beatriz Martinez Garcia.

Proyecto académico de Tecnología en Desarrollo de Software, Fundación Universitaria Tecnológico Comfenalco, 2026.
