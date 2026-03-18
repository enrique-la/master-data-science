"""
Script para convertir Markdown a PDF
Requiere: pip install markdown pdfkit
Alternativa si no funciona: pip install markdown reportlab
"""

# Opción 1: Usando markdown2pdf (más simple)
try:
    import markdown
    from weasyprint import HTML

    # Leer el archivo markdown
    with open('Chuleta_IntroML.md', 'r', encoding='utf-8') as f:
        md_content = f.read()

    # Convertir markdown a HTML
    html_content = markdown.markdown(md_content, extensions=['fenced_code', 'tables', 'codehilite'])

    # Agregar estilos CSS para mejorar la apariencia
    styled_html = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <style>
            body {{
                font-family: Arial, sans-serif;
                line-height: 1.6;
                max-width: 800px;
                margin: 20px;
                color: #333;
            }}
            h1 {{
                color: #2c3e50;
                border-bottom: 3px solid #3498db;
                padding-bottom: 10px;
            }}
            h2 {{
                color: #34495e;
                border-bottom: 2px solid #95a5a6;
                padding-bottom: 5px;
                margin-top: 30px;
            }}
            h3 {{
                color: #7f8c8d;
                margin-top: 20px;
            }}
            code {{
                background-color: #f4f4f4;
                padding: 2px 6px;
                border-radius: 3px;
                font-family: 'Courier New', monospace;
                font-size: 0.9em;
            }}
            pre {{
                background-color: #f4f4f4;
                padding: 15px;
                border-left: 4px solid #3498db;
                overflow-x: auto;
                border-radius: 5px;
            }}
            pre code {{
                background-color: transparent;
                padding: 0;
            }}
            ul, ol {{
                margin-left: 20px;
            }}
            strong {{
                color: #2980b9;
            }}
            hr {{
                border: none;
                border-top: 2px solid #ecf0f1;
                margin: 30px 0;
            }}
        </style>
    </head>
    <body>
        {html_content}
    </body>
    </html>
    """

    # Convertir HTML a PDF
    HTML(string=styled_html).write_pdf('Chuleta_IntroML.pdf')
    print("✓ PDF creado exitosamente: Chuleta_IntroML.pdf")

except ImportError as e:
    print(f"Error: Falta instalar librerías. {e}")
    print("\nIntenta instalar con:")
    print("pip install markdown weasyprint")
    print("\nO usa la opción alternativa más abajo...")

    # Opción 2: Alternativa usando reportlab (más básica pero no requiere weasyprint)
    print("\n" + "="*60)
    print("OPCIÓN ALTERNATIVA (más simple, sin formato avanzado):")
    print("="*60)

    try:
        from reportlab.lib.pagesizes import letter, A4
        from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
        from reportlab.lib.units import inch
        from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak, Preformatted
        from reportlab.lib.enums import TA_LEFT
        from reportlab.pdfbase import pdfmetrics
        from reportlab.pdfbase.ttfonts import TTFont

        # Leer el archivo markdown
        with open('Chuleta_IntroML.md', 'r', encoding='utf-8') as f:
            md_lines = f.readlines()

        # Crear PDF
        pdf_file = "Chuleta_IntroML_simple.pdf"
        doc = SimpleDocTemplate(pdf_file, pagesize=A4,
                                rightMargin=72, leftMargin=72,
                                topMargin=72, bottomMargin=18)

        # Estilos
        styles = getSampleStyleSheet()
        styles.add(ParagraphStyle(name='Code',
                                  fontName='Courier',
                                  fontSize=8,
                                  leftIndent=20,
                                  textColor='black'))

        story = []
        in_code_block = False
        code_buffer = []

        for line in md_lines:
            line = line.rstrip()

            # Detectar bloques de código
            if line.startswith('```'):
                if in_code_block:
                    # Fin del bloque de código
                    code_text = '\n'.join(code_buffer)
                    story.append(Preformatted(code_text, styles['Code']))
                    story.append(Spacer(1, 0.2*inch))
                    code_buffer = []
                in_code_block = not in_code_block
                continue

            if in_code_block:
                code_buffer.append(line)
                continue

            # Títulos y contenido
            if line.startswith('# '):
                story.append(Paragraph(line[2:], styles['Title']))
                story.append(Spacer(1, 0.3*inch))
            elif line.startswith('## '):
                story.append(Paragraph(line[3:], styles['Heading1']))
                story.append(Spacer(1, 0.2*inch))
            elif line.startswith('### '):
                story.append(Paragraph(line[4:], styles['Heading2']))
                story.append(Spacer(1, 0.15*inch))
            elif line.startswith('---'):
                story.append(Spacer(1, 0.3*inch))
            elif line.strip():
                # Texto normal
                story.append(Paragraph(line, styles['BodyText']))
                story.append(Spacer(1, 0.1*inch))

        # Construir PDF
        doc.build(story)
        print(f"\n✓ PDF alternativo creado: {pdf_file}")

    except ImportError as e2:
        print(f"\nError en opción alternativa: {e2}")
        print("\nIntenta: pip install reportlab")
