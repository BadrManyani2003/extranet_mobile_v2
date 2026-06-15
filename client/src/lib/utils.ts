import { type ClassValue, clsx } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

export function formatCurrency(val: number | string | undefined | null): string {
  if (val === undefined || val === null || val === '') return '0.00'
  
  const num = typeof val === 'string' ? parseFloat(val.replace(/[^\d.-]/g, '')) : val
  if (isNaN(num)) return String(val)
  
  const parts = num.toFixed(2).split('.')
  parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ' ')
  return parts.join('.')
}

export function formatNumber(val: number | string | undefined | null): string {
  if (val === undefined || val === null) return '0'
  const num = typeof val === 'string' ? parseFloat(val.replace(/[^\d.-]/g, '')) : val
  if (isNaN(num)) return String(val)
  
  const parts = num.toString().split('.')
  parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ' ')
  return parts.join('.')
}


export function formatDate(date: string | Date | null | undefined): string {
  if (!date) return '-'
  const d = new Date(date)
  if (isNaN(d.getTime())) {
    const s = String(date)
    if (s.includes('T')) return s.split('T')[0].split('-').reverse().join('/')
    return s
  }
  const day = String(d.getDate()).padStart(2, '0')
  const month = String(d.getMonth() + 1).padStart(2, '0')
  const year = d.getFullYear()
  return `${day}/${month}/${year}`
}

export function formatKPIValue(val: number | string | undefined | null, type: 'currency' | 'number' | 'percentage' = 'number'): string {
  if (val === undefined || val === null || val === '') return '0'
  const num = typeof val === 'string' ? parseFloat(val) : val
  if (isNaN(num)) return String(val)

  if (type === 'currency') {
    if (num >= 1000000) {
      const formatted = (num / 1000000).toFixed(2).replace('.', ',')
      return `${formatted} M MAD`
    } else {
      const formatted = Math.round(num).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ' ')
      return `${formatted} MAD`
    }
  } else if (type === 'percentage') {
    return num.toFixed(1).replace('.', ',') + ' %'
  } else {
    if (num % 1 !== 0) {
      const parts = num.toFixed(3).split('.')
      parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ' ')
      return parts.join(',')
    }
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ' ')
  }
}