// @ts-ignore
import html2pdf from 'html2pdf.js'

interface PdfExportOptions {
  elementId: string
  filename?: string
  onComplete?: () => void
  onError?: (err: any) => void
}

/**
 * Exporte un élément HTML en PDF au format A4.
 * Force la largeur à 1200px pour un affichage "desktop" complet et gère les sauts de page.
 */
export const exportDashboardToPdf = ({
  elementId,
  filename = 'Statistiques.pdf',
  onComplete,
  onError
}: PdfExportOptions) => {
  const element = document.getElementById(elementId)
  if (!element) {
    if (onError) onError(new Error(`Element with id ${elementId} not found.`))
    return
  }

  // Active le mode d'exportation
  element.classList.add('pdf-export-mode')
  
  const opt = {
    // Top, Left, Bottom, Right margin
    margin: [10, 10, 15, 10] as [number, number, number, number],
    filename,
    image: { type: 'jpeg' as const, quality: 1 },
    html2canvas: {
      scale: 2,
      useCORS: true,
      logging: false,
      windowWidth: 1200,
      width: 1200, // Force canvas width
      scrollX: 0,
      scrollY: 0,
      onclone: (clonedDoc: Document) => {
        const el = clonedDoc.getElementById(elementId)
        if (el) {
          // Dans le clone sécurisé, on force les dimensions desktop
          clonedDoc.body.style.width = '1200px'
          el.style.width = '1200px'
          el.style.maxWidth = '1200px'
          el.style.margin = '0 auto'
        }
      }
    },
    jsPDF: {
      unit: 'mm',
      format: 'a4',
      orientation: 'portrait' as const
    },
    pagebreak: {
      mode: ['css', 'legacy'],
      avoid: ['.pdf-avoid-break'],
      before: ['.pdf-page-break']
    }
  }

  // Wait for the browser to apply the 1200px width from the CSS before html2pdf measures it
  setTimeout(() => {
    html2pdf()
      .set(opt)
      .from(element)
      .save()
      .then(() => {
        element.classList.remove('pdf-export-mode')
        if (onComplete) onComplete()
      })
      .catch((err: any) => {
        console.error('Error exporting PDF:', err)
        element.classList.remove('pdf-export-mode')
        if (onError) onError(err)
      })
  }, 200)
}
