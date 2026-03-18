"""
Script simple para convertir Markdown a PDF usando reportlab
"""

from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch, cm
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Preformatted
from reportlab.lib.enums import TA_LEFT, TA_JUSTIFY
import re

# Leer el archivo markdown
with open('Chuleta_IntroML.md', 'r', encoding='utf-8') as f:
    md_lines = f.readlines()

# Crear PDF
pdf_file = "Chuleta_IntroML.pdf"
doc = SimpleDocTemplate(
    pdf_file,
    pagesize=A4,
    rightMargin=2*cm,
    leftMargin=2*cm,
    topMargin=2*cm,
    bottomMargin=2*cm
)

# Estilos base
styles = getSampleStyleSheet()

# Crear estilos personalizados
style_code = ParagraphStyle(
    'CustomCode',
    parent=styles['Code'],
    fontName='Courier',
    fontSize=7,
    leftIndent=10,
    textColor='black',
    backColor='lightgrey',
    spaceBefore=6,
    spaceAfter=6
)

style_h1 = ParagraphStyle(
    'CustomH1',
    parent=styles['Heading1'],
    fontSize=16,
    textColor='darkblue',
    spaceAfter=12,
    spaceBefore=12
)

style_h2 = ParagraphStyle(
    'CustomH2',
    parent=styles['Heading2'],
    fontSize=13,
    textColor='blue',
    spaceAfter=10,
    spaceBefore=10
)

style_h3 = ParagraphStyle(
    'CustomH3',
    parent=styles['Heading3'],
    fontSize=11,
    textColor='navy',
    spaceAfter=8,
    spaceBefore=8
)

style_body = ParagraphStyle(
    'CustomBody',
    parent=styles['BodyText'],
    fontSize=9,
    alignment=TA_JUSTIFY,
    spaceAfter=6
)

story = []
in_code_block = False
code_buffer = []

# Procesar línea por línea
for line in md_lines:
    line = line.rstrip()

    # Detectar bloques de código
    if line.startswith('```'):
        if in_code_block:
            # Fin del bloque de código
            if code_buffer:
                code_text = '\n'.join(code_buffer)
                # Escapar caracteres especiales para reportlab
                code_text = code_text.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
                story.append(Preformatted(code_text, style_code))
                story.append(Spacer(1, 0.1*inch))
            code_buffer = []
        in_code_block = not in_code_block
        continue

    if in_code_block:
        code_buffer.append(line)
        continue

    # Procesar títulos y contenido normal
    if line.startswith('# '):
        text = line[2:].strip()
        story.append(Paragraph(text, style_h1))

    elif line.startswith('## '):
        text = line[3:].strip()
        story.append(Paragraph(text, style_h2))

    elif line.startswith('### '):
        text = line[4:].strip()
        story.append(Paragraph(text, style_h3))

    elif line.startswith('---'):
        story.append(Spacer(1, 0.3*inch))

    elif line.strip().startswith('-') or line.strip().startswith('*'):
        # Listas
        text = line.strip()[1:].strip()
        if text:
            text = '• ' + text
            story.append(Paragraph(text, style_body))

    elif line.strip():
        # Texto normal
        text = line.strip()
        # Escapar caracteres especiales
        text = text.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
        # Mantener el formato de código inline con `
        text = text.replace('`', '<font name="Courier" size=8 backColor="lightgrey">')
        text = text.replace('`', '</font>')
        story.append(Paragraph(text, style_body))
    else:
        # Línea vacía
        story.append(Spacer(1, 0.05*inch))

# Construir PDF
try:
    doc.build(story)
    print(f"✓ PDF creado exitosamente: {pdf_file}")
    print(f"✓ Ubicación: c:\\Users\\enriq\\Desktop\\Master\\Data Science\\Clases Juan\\Día 5 (Intro ML)\\Práctica\\{pdf_file}")
except Exception as e:
    print(f"Error al crear PDF: {e}")
