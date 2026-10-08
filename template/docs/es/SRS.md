# SRS — Software Requirements Specification

🌍 **Lee esto en:** [Español](SRS.md) | [English](../en/SRS.md)

> **Estado:** Pendiente de redacción.
> **Instrucciones:** Usar el Prompt 2 (`docs/es/prompts/02-SRS.md`) con DeepSeek web.
> **Depende de:** `docs/es/PRD-SRD.md`
> **Alimenta a:** `docs/es/Propuesta_Tecnica.md`, `docs/es/Plan_Pruebas.md`
> **Estándar:** IEEE 830 / ISO 29148

---

## 1. Introducción

### 1.1. Propósito
[Pendiente: qué hace este documento y a quién va dirigido.]

### 1.2. Alcance
[Pendiente: qué cubre y qué no.]

### 1.3. Definiciones, acrónimos y abreviaturas

| Término | Definición |
|---------|------------|
| [Término] | [Definición] |

### 1.4. Referencias
- `docs/es/PRD-SRD.md`
- [Otros documentos de referencia]

## 2. Descripción general

### 2.1. Perspectiva del producto
[Pendiente: cómo encaja el sistema en el contexto del usuario.]

### 2.2. Funciones principales
- [Función 1]
- [Función 2]

### 2.3. Usuarios objetivo
[Pendiente: referencia a las personas del PRD-SRD.]

### 2.4. Restricciones generales
- [Restricción 1]

### 2.5. Supuestos y dependencias
- [Supuesto o dependencia]

## 3. Requisitos funcionales

### RF-001: [Título]
- **Descripción:** [Descripción detallada]
- **Prioridad:** [Alta/Media/Baja]
- **Trazabilidad:** HU-001 (PRD-SRD)
- **Criterios de aceptación:**
  - [ ] [Criterio 1]
  - [ ] [Criterio 2]

## 4. Requisitos no funcionales

### 4.1. Rendimiento
- **RNF-PERF-001:** [Requisito con métrica concreta]

### 4.2. Seguridad
- **RNF-SEC-001:** [Requisito con métrica concreta]

### 4.3. Usabilidad
- **RNF-USA-001:** [Requisito]

### 4.4. Disponibilidad
- **RNF-AVAIL-001:** [Requisito con uptime objetivo]

### 4.5. Mantenibilidad
- **RNF-MANT-001:** [Requisito, ej. cobertura de tests]

### 4.6. Portabilidad
- **RNF-PORT-001:** [Requisito, ej. sistemas soportados]

## 5. Interfaces externas

### 5.1. Interfaces de usuario
[Pendiente: descripción de la UI.]

### 5.2. Interfaces de hardware
[Pendiente: si aplica.]

### 5.3. Interfaces de software
| Sistema externo | Protocolo | Propósito |
|-----------------|-----------|-----------|
| [API externa] | [REST/gRPC] | [Propósito] |

### 5.4. Interfaces de comunicación
[Pendiente: protocolos de red.]

## 6. Restricciones de diseño

- [Restricción técnica]
- [Restricción regulatoria]
- [Restricción de negocio]

## 7. Matriz de trazabilidad

| HU (PRD-SRD) | RF (SRS) | RNF (SRS) |
|--------------|----------|-----------|
| HU-001 | RF-001 | RNF-SEC-001 |