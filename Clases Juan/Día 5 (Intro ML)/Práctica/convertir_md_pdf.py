"""
Script super simple para convertir Markdown a PDF
"""

from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib.units import cm
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Preformatted
from reportlab.lib.colors import HexColor

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

# Estilos
styles = getSampleStyleSheet()
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
                story.append(Preformatted(code_text, styles['Code']))
                story.append(Spacer(1, 0.3*cm))
            code_buffer = []
        in_code_block = not in_code_block
        continue

    if in_code_block:
        code_buffer.append(line)
        continue

    # Procesar títulos y contenido normal
    if line.startswith('# '):
        text = line[2:].strip()
        story.append(Spacer(1, 0.5*cm))
        story.append(Paragraph('<b><font size=16 color="darkblue">' + text + '</font></b>', styles['BodyText']))
        story.append(Spacer(1, 0.3*cm))

    elif line.startswith('## '):
        text = line[3:].strip()
        story.append(Spacer(1, 0.4*cm))
        story.append(Paragraph('<b><font size=13 color="blue">' + text + '</font></b>', styles['BodyText']))
        story.append(Spacer(1, 0.2*cm))

    elif line.startswith('### '):
        text = line[4:].strip()
        story.append(Spacer(1, 0.3*cm))
        story.append(Paragraph('<b><font size=11 color="navy">' + text + '</font></b>', styles['BodyText']))
        story.append(Spacer(1, 0.15*cm))

    elif line.startswith('---'):
        story.append(Spacer(1, 0.5*cm))

    elif line.strip().startswith('-') or line.strip().startswith('*'):
        # Listas
        text = line.strip()
        if len(text) > 1:
            text = text[1:].strip()
            if text and '**' not in text:  # Evitar problemas con negritas
                # Limpiar el texto
                text = text.replace('`', "'").replace('**', '').replace('<', '&lt;').replace('>', '&gt;')
                story.append(Paragraph('• ' + text, styles['Normal']))

    elif line.strip() and not line.startswith('#'):
        # Texto normal
        text = line.strip()
        # Limpiar caracteres problemáticos
        text = text.replace('`', "'").replace('**', '').replace('<', '&lt;').replace('>', '&gt;')
        if text and len(text) > 0:
            try:
                story.append(Paragraph(text, styles['Normal']))
            except:
                # Si falla, añadir como preformateado
                story.append(Preformatted(text, styles['Code']))
    else:
        # Línea vacía
        story.append(Spacer(1, 0.1*cm))

# Construir PDF
try:
    doc.build(story)
    print("="*60)
    print("PDF creado exitosamente!")
    print("="*60)
    print("\nArchivo: Chuleta_IntroML.pdf")
    print("\nUbicacion completa:")
    print("c:\\Users\\enriq\\Desktop\\Master\\Data Science\\Clases Juan\\Dia 5 (Intro ML)\\Practica\\Chuleta_IntroML.pdf")
    print("="*60)
except Exception as e:
    print(f"Error al crear PDF: {e}")
