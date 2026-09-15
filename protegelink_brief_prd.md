# 📄 Project Brief & Product Requirements Document (PRD)
## ProtegeLink: Escudo Digital y Navegador Seguro para Adultos Mayores

---

### 1. Resumen Ejecutivo (Executive Summary)
**ProtegeLink** es una aplicación móvil para Android concebida como un **navegador de confianza y escudo digital preventivo**, diseñada con un enfoque prioritario en la accesibilidad cognitiva, visual y motora de personas mayores de 60 años. 

La solución actúa interceptando y analizando enlaces web provenientes de canales habituales de mensajería (WhatsApp, SMS, correo electrónico) antes de que el usuario acceda a ellos, detectando intentos de phishing, suplantación de identidad bancaria y estafas digitales. Toda la retroalimentación se entrega en un lenguaje empático, humano y libre de tecnicismos, reduciendo la ansiedad y promoviendo la autonomía digital.

---

### 2. Definición del Problema & Oportunidad
* **Vulnerabilidad al cibercrimen:** Los adultos mayores son blanco principal de técnicas de ingeniería social que explotan la urgencia ("Su cuenta bancaria ha sido bloqueada", "Premio exclusivo").
* **Barreras cognitivas con la ciberseguridad:** Los navegadores tradicionales presentan advertencias crípticas ("ERR_CERT_COMMON_NAME_INVALID", "Phishing detectado") que causan pánico o son ignoradas sin comprensión.
* **Aislamiento en la toma de decisiones:** Ante una duda, el adulto mayor suele sentirse avergonzado de preguntar repetidamente a sus familiares o desconoce cómo compartir el enlace de forma segura.
* **Oportunidad:** Un sistema centrado en la tranquilidad, con validación asistida en un solo toque, pedagogía preventiva y un canal directo de consulta con contactos familiares de confianza.

---

### 3. Perfil de Usuario & Accesibilidad (Target Personas)
* **Población Objetivo:** Adultos de 60+ años en Latinoamérica / hispanohablantes.
* **Competencias Digitales:** Bajas a intermedias; usuarios asiduos de WhatsApp y llamadas telefónicas, pero con desconfianza en trámites web complejos.
* **Limitaciones Sensoriomotoras:**
  * **Visual:** Presbicia, cataratas o menor agudeza visual. Requiere alto contraste (WCAG AAA), fuentes grandes (>16-20sp) y jerarquía sin saturación.
  * **Motor:** Temblor leve, reducción de precisión táctil. Requiere áreas de contacto mínimas de **48dp a 56dp**.
  * **Cognitivo:** Fatiga visual rápida ante exceso de opciones. Requiere arquitectura ultra-plana (máximo 3 niveles de profundidad, 1 acción primaria por pantalla).

---

### 4. Principios Rectores de Diseño (Design Principles)
1. **Tranquilidad ante todo:** No emitir alertas culpabilizadoras ni alarmistas. Mensajes serenos como *"No te preocupes, cuidamos tus fotos y ahorros"*.
2. **Cero jerga técnica:** Sustituir "Phishing", "TLS/SSL", "Blacklist" o "Malware" por explicaciones humanas: *"Página reportada por la comunidad"*, *"Intenta imitar a un banco"*, *"Conexión no protegida"*.
3. **Comunicación multi-sensorial:** Nunca transmitir seguridad únicamente con color; acompañar siempre con texto legible e iconografía robusta (escudos, candados, tildes, símbolos de advertencia).
4. **Navegación superficial (Zero Dark Patterns):** Barra inferior con solo 3 destinos: **Inicio**, **Historial** y **Ayuda**. Enlaces peligrosos con desestimación deliberada del botón para continuar.

---

### 5. Arquitectura de Navegación & Pantallas Clave

```
[Onboarding / Bienvenida] ---> [Activar Protección (3 Pasos)]
                                         │
                                         ▼
                                 [INICIO PRINCIPAL]
                                  (Estado: Activo)
                                         │
       ┌─────────────────────────────────┼────────────────────────────────┐
       ▼                                 ▼                                ▼
[Pegar Enlace Manual]           [Interceptar Enlace]              [Historial & Ayuda]
       │                                 │                                │
       └────────────────┬────────────────┘                                │
                        ▼                                                 ▼
             [Analizando Enlace...]                              [Consejos / Soporte]
                        │
       ┌────────────────┼────────────────┐
       ▼                ▼                ▼
[Sitio Seguro]   [Sospechoso]     [Sitio Bloqueado]
 (Abrir Web)     (Advertencia)    (Peligro Crítico)
                        │                │
                        └───────┬────────┘
                                ▼
                   [Detalles de Análisis]
                                │
                                ▼
                 [Modal Consulta Familiar]
                 (WhatsApp / Llamada Directa)
```

#### Catálogo de Pantallas Implementadas:
1. **Bienvenida / Onboarding:** Introducción cálida con propuesta de valor única ("Tu escudo digital diario").
2. **Activar Navegador Seguro:** Proceso pedagógico en 3 pasos claros para fijar la app como navegador predeterminado en Android.
3. **Inicio (Protección Activa):** Gran indicador verde de estatus, botón de escaneo manual y últimos enlaces.
4. **Revisar Enlace Manual:** Opción accesible de pegado en 1 toque desde el portapapeles con tutorial guiado.
5. **Analizando Enlace:** Retroalimentación de progreso sereno sin tecnicismos ("Comprobando sitios oficiales").
6. **Resultado Seguro:** Validación verde, dominio legible, navegación directa.
7. **Resultado Sospechoso:** Advertencia preventiva ámbar con motivos desglosados y opción "Volver a un lugar seguro".
8. **Sitio Bloqueado:** Bloqueo rojo de protección activa contra robo de datos bancarios.
9. **Detalles del Análisis:** Traducción en palabras simples de por qué se detuvo el sitio y 3 recomendaciones de acción.
10. **Consultar con un Familiar (Modal Bottom Sheet):** Previsualización de mensaje a enviar por WhatsApp a un contacto asignado ("Mariana - Hija") o llamada directa.
11. **Historial de Enlaces:** Registro cronológico con etiquetas de estado y botón accesible para limpiar registros.
12. **Ayuda, Consejos & Soporte:** Tarjetas educativas ("Regla de oro bancaria") y botón de llamada telefónica gratuita.
13. **Configuración:** Ajuste de tamaño de tipografía, sonidos suaves y estado de protección.

---

### 6. Especificaciones Técnicas & Viabilidad (Stack Recomendado)
* **Framework:** **Flutter** (Dart) o **Jetpack Compose** (Kotlin nativo en Android).
* **Mecanismo de Intercepción Android:**
  * Declaración de `IntentFilter` para esquemas `http` y `https` en `AndroidManifest.xml` con categoría `DEFAULT` y `BROWSABLE`.
  * Integración con `RoleManager` (Android 10+) para solicitar el rol `ROLE_BROWSER` de manera oficial.
* **Motor de Análisis & Ciberseguridad:**
  * Microservicio backend (API REST) que consulta fuentes confiables: *Google Safe Browsing API*, *VirusTotal*, listados locales de dominios bancarios autorizados y bases de datos anti-phishing comunitarias.
  * Algoritmo de distancia de Levenshtein para detección de *typosquatting* (ej. `banco-santander-av.com` vs `bancosantander.com.ar`).
* **Almacenamiento Local Seguro:** SQLite / Drift con cifrado SQLCipher para el historial de enlaces y credenciales de contacto de emergencia.

---

### 7. Métricas de Éxito (KPIs de Producto)
1. **Tasa de éxito de activación (Onboarding Funnel):** >85% de usuarios que completan la asignación como navegador predeterminado.
2. **Efectividad de prevención de incidentes:** 0 accesos involuntarios a sitios categorizados como bloqueados.
3. **Satisfacción y Reducción de Ansiedad (NPS & SUS):** Puntuación en la escala SUS (System Usability Scale) >80 en pruebas con usuarios de 60+.
4. **Tasa de resolución familiar:** >60% de usuarios que reciben una alerta sospechosa recurren al botón *"Consultar con un familiar"*.
