# Demostración final de ProtegeLink

Este guion dura aproximadamente cinco minutos. Usa dominios `.test` y la red `192.0.2.0/24`, reservados para pruebas y documentación. No utiliza sitios reales de phishing.

ProtegeLink es un proyecto académico: las heurísticas pueden producir falsos positivos o falsos negativos y no garantizan detectar todas las amenazas.

## Preparación

### Backend

Desde `backend/`, copiar `.env.example` a `.env` y configurar:

```dotenv
GOOGLE_SAFE_BROWSING_API_KEY=
DEMO_MODE=true
```

Después ejecutar:

```powershell
.\.venv\Scripts\Activate.ps1
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

`DEMO_MODE` está desactivado por defecto. Solo reconoce las tres URLs exactas de esta guía y agrega una razón visible que identifica el caso como demostración controlada.

### Emulador Android

```powershell
cd mobile
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

El override es útil para el emulador porque `10.0.2.2` apunta a la computadora anfitriona.

### Teléfono físico

El teléfono y la notebook deben conectarse al mismo hotspot. Generar e instalar el APK sin parámetros especiales:

```powershell
cd mobile
flutter build apk --release
```

En el teléfono, abrir **Configuración → Dirección del backend** e ingresar la IPv4 real de la notebook y el puerto, por ejemplo `http://192.168.43.25:8000`. La dirección queda guardada y puede cambiarse cada vez que el hotspot asigne otra IP. No usar `localhost`, porque en el teléfono apunta al propio teléfono.

Como alternativa, la dirección inicial del APK se cambia en `mobile/lib/core/constants/app_config.dart`, constante `bundledApiBaseUrl`, antes de compilar.

## Guion de cinco minutos

### 1. Abrir ProtegeLink

Mostrar el onboarding: la aplicación revisa enlaces, advierte sobre posibles riesgos y no garantiza detectar todas las amenazas. Pulsar **Comenzar** y enseñar Inicio con **Protección activa**.

### 2. SAFE

Pulsar **Revisar un enlace** y analizar:

```text
https://safe.demo.protegelink.test
```

Resultado esperado: `SAFE`, puntaje 0. Explicar que el caso está aislado dentro de `DEMO_MODE`. Mostrar dominio, explicación, **Abrir sitio** y **Volver**. No es necesario abrir este dominio ficticio.

### 3. SUSPICIOUS

Analizar:

```text
http://login.account.verify.demo.protegelink.test
```

Resultado esperado: `SUSPICIOUS`, puntaje 40. Explicar las señales: HTTP sin cifrar, estructura con muchos subdominios y varias palabras sensibles. Mostrar **Ver detalles**.

### 4. DANGEROUS

Analizar:

```text
http://192.0.2.1/login/verify/account/security/password
```

Resultado esperado: `DANGEROUS`, puntaje 80. Mostrar que la interfaz dice **Sitio bloqueado** y no ofrece **Abrir sitio**.

### 5. Historial y persistencia

Abrir **Historial**. Los tres casos deben aparecer del más reciente al más antiguo con dominio, fecha, estado e icono. Tocar una entrada para abrir sus detalles. Cerrar completamente ProtegeLink, volver a abrirlo y demostrar que SQLite conserva los registros.

### 6. Compartir desde Chrome u otra aplicación

Compartir un texto que contenga:

```text
https://safe.demo.protegelink.test
```

Elegir **ProtegeLink**. La pantalla **Revisar un enlace** debe abrirse con la URL precargada; el análisis comienza únicamente al pulsar el botón.

### 7. ACTION_VIEW opcional

Tocar un enlace HTTP/HTTPS desde otra aplicación y elegir ProtegeLink en el selector Android. También se puede abrir **Configuración → Usar ProtegeLink para abrir enlaces** para mostrar los ajustes de aplicaciones predeterminadas. La selección nunca es obligatoria.

## Explicación técnica breve

```text
Android / Flutter
        ↓
FastAPI
        ↓
Heurísticas + Safe Browsing
        ↓
SAFE / SUSPICIOUS / DANGEROUS
        ↓
SQLite + interfaz accesible
```

- Flutter normaliza la URL, valida, presenta carga, traduce las razones y guarda el resultado.
- Kotlin entrega a Flutter enlaces recibidos mediante `ACTION_SEND` y `ACTION_VIEW`.
- FastAPI analiza solamente la dirección; no descarga la página ni navega desde el servidor.
- Safe Browsing es opcional. Sin API key o ante un fallo, continúan las heurísticas.
- SQLite conserva URL, dominio, estado, puntaje, razones y fecha dentro del teléfono.

## Si algo falla durante la presentación

- Confirmar que `/health` responde desde la notebook.
- Confirmar que el backend usa `--host 0.0.0.0`.
- Confirmar que teléfono y notebook están en la misma red.
- Confirmar en **Configuración → Dirección del backend** que figuran la IP real de la notebook y el puerto 8000.
- Confirmar que `DEMO_MODE=true` está en `backend/.env` y reiniciar Uvicorn después de cambiarlo.

