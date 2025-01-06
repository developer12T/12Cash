import { defineStore } from 'pinia'
import { sprintf } from 'sprintf-js'

export const useReceiptStore = defineStore('receipt', {
  state: () => ({
    receiptData: null,
    vowelAndToneMark: [
      '่',
      '้',
      '๊',
      '๋',
      'ั',
      '็',
      'ิ',
      'ี',
      'ุ',
      'ู',
      'ึ',
      'ื',
      '์',
      '.'
    ]
  }),
  actions: {
    getNoOfUpperLowerChar (string) {
      let counter = 0
      for (let char of string) {
        if (this.vowelAndToneMark.includes(char)) {
          counter++
        }
      }
      return counter
    },
    leftRightText (left, right, width) {
      const space = Math.max(0, width - left.length - right.length)
      return left + ' '.repeat(space) + right
    },

    centerText (text, width) {
      const leftPadding = Math.max(0, Math.floor((width - text.length) / 2))
      return ' '.repeat(leftPadding) + text
    },
    leftText (text, width) {
      return text.padEnd(width)
    },
    rightText (text, width) {
      return text.padStart(width)
    },
    padThaiText (text, length) {
      let extraSpaces = this.getNoOfUpperLowerChar(text)
      return text.padEnd(length + extraSpaces)
    },

    formatReceiptCA (data) {
      const paperWidth = 72

      const header = `
${this.centerText('บริษัท วันทูเทรดดิ้ง จำกัด', paperWidth)}
${this.centerText('58/3 หมู่ที่ 6 ถ.พระประโทน-บ้านแพ้ว', paperWidth)}
${this.centerText('ต.ตลาดจินดา อ.สามพราน จ.นครปฐม 73110', paperWidth)}
${this.centerText('โทร.(034) 981-555', paperWidth)}
${this.centerText('เลขประจำตัวผู้เสียภาษี 0105563063410', paperWidth)}
${this.centerText('ออกใบกำกับภาษีโดยสำนักงานใหญ่', paperWidth)}
${this.centerText('(บิลเงินสด/ใบกำกับภาษี)', paperWidth)}
${this.centerText('เอกสารออกเป็นชุด', paperWidth)}
${this.leftRightText(
  `รหัสลูกค้า ${data.customer.customercode}`,
  `เลขที่ ${data.CUOR}`,
  paperWidth
)}
${this.leftRightText(
  `ชื่อลูกค้า ${this.padThaiText(data.customer.customername, 42)}`,
  `วันที่ ${data.OAORDT}`,
  paperWidth
)}
ที่อยู่ ${data.customer.address1}
${data.customer.address2}
${data.customer.address3} ${data.customer.postCode}
เลขที่ผู้เสียภาษี ${data.customer.taxno}
 
รายการสินค้า                         จำนวน    ราคา     ส่วนลด       รวม
`

      const formatItem = (no, name, qty, price, discount, total) => {
        const itemQty = this.padThaiText(qty, 7)
        const itemPrice = this.padThaiText(this.rightText(price, 6), 6)
        const itemDiscount = discount.padStart(6)
        const itemTotal = total.padStart(11)

        return `${no} ${this.padThaiText(
          name,
          31
        )} ${itemQty} ${itemPrice} ${itemDiscount} ${itemTotal}`
      }

      const items = data.items
        .map((item, index) =>
          formatItem(
            // item.itemCode.toString(),
            index + 1,
            item.itemname.replace(' ', '').substring(0, 36),
            item.qtytext,
            item.OBSAPR,
            item.disamount,
            item.itemamount
          )
        )
        .join('\n')
      const totalText = thaiNumberToWords(data.totaltext)
      const footer = `
 
${this.leftRightText('รวมมูลค่าสินค้า', `${data.ex_vat}`, '73')}
${this.leftRightText('ส่วนลด', '0.00', '70')}
${this.leftRightText('ภาษีมูลค่าเพิ่ม 7%', `${data.vat}`, '74')}
${this.leftRightText('ส่วนลดท้ายบิล', '0.00', paperWidth)}
${this.leftRightText('ส่วนลดร้านค้า', `${data.totaldis}`, paperWidth)}
${this.leftRightText('จำนวนเงินรวมสุทธิ', `${data.total}`, paperWidth)}
${this.rightText(`(${totalText})`, paperWidth)}
${this.leftRightText('', '', '70')}
${this.leftRightText(
  `ผู้รับเงิน ${data.OBSMCD}`,
  '.........................',
  '70'
)}
${this.leftRightText('', 'ลายเซ็นลูกค้า', '63')}
 
 
 
      `

      return header + items + footer
    },

    formatReceiptReturn (data) {
      const paperWidth = 72

      const header1 = `
${this.centerText('บริษัท วันทูเทรดดิ้ง จำกัด', paperWidth)}
${this.centerText('58/3 หมู่ที่ 6 ถ.พระประโทน-บ้านแพ้ว', paperWidth)}
${this.centerText('ต.ตลาดจินดา อ.สามพราน จ.นครปฐม 73110', paperWidth)}
${this.centerText('โทร.(034) 981-555', paperWidth)}
${this.centerText('เลขประจำตัวผู้เสียภาษี 0105563063410', paperWidth)}
${this.centerText('ออกใบกำกับภาษีโดยสำนักงานใหญ่', paperWidth)}
${this.centerText('(ใบลดหนี้)', paperWidth)}
${this.centerText('เอกสารออกเป็นชุด', paperWidth)}
${this.leftRightText(
  `รหัสลูกค้า ${data.customer.customercode}`,
  `เลขที่ ${data.returnno}`,
  paperWidth
)}
${this.leftRightText(
  `ชื่อลูกค้า ${this.padThaiText(data.customer.customername, 42)}`,
  `วันที่ ${data.OAORDT}`,
  paperWidth
)}
ที่อยู่ ${data.customer.address1}
${data.customer.address2}
${data.customer.address3} ${data.customer.postCode}
เลขที่ผู้เสียภาษี ${data.customer.taxno}
   
สินค้าที่รับมาจากร้านค้า
---------------------------------------------------------------------
รายการสินค้า                        จำนวน    ราคา     ส่วนลด       รวม
`

      const formatItem1 = (no, name, qty, price, discount, total) => {
        const itemQty = this.padThaiText(qty, 7)
        const itemPrice = this.rightText(this.padThaiText(price, 6), 6)
        const itemDiscount = discount.padStart(6)
        const itemTotal = total.padStart(11)

        return `${no} ${this.padThaiText(
          name,
          31
        )} ${itemQty} ${itemPrice} ${itemDiscount} ${itemTotal}`
      }

      const items1 = data.returnItems
        .map((item, index) =>
          formatItem1(
            index + 1,
            item.itemname.replace(' ', '').substring(0, 36),
            item.qtytext,
            parseFloat(item.OBSAPR).toFixed(2).toString(),
            parseFloat(item.totaldis).toFixed(2).toString(),
            parseFloat(item.itemamount).toFixed(2).toString()
          )
        )
        .join('\n')

      const totalText1 = thaiNumberToWords(data.returntotaltext)
      const footer1 = `
   
${this.leftRightText(
  'รวมมูลค่าสินค้า',
  `${parseFloat(data.returnex_vat).toFixed(2)}`,
  '73'
)}
${this.leftRightText('ส่วนลด', '0.00', '70')}
${this.leftRightText(
  'ภาษีมูลค่าเพิ่ม 7%',
  `${parseFloat(data.returnvat).toFixed(2)}`,
  '74'
)}
${this.leftRightText(
  'จำนวนเงินรวมสุทธิ',
  `${parseFloat(data.returntotal).toFixed(2)}`,
  paperWidth
)}
${this.rightText(`(${totalText1})`, paperWidth)}
${this.leftRightText('', '', '70')}
${this.leftRightText(
  `ผู้รับเงิน ${data.customer.salecode}`,
  '.........................',
  '70'
)}
${this.leftRightText('', 'ลายเซ็นลูกค้า', '63')}
 
 
 
-------------------------------ตัดตามรอยปะ----------------------------
 
 
`
      const header2 = `
${this.centerText('บริษัท วันทูเทรดดิ้ง จำกัด', paperWidth)}
${this.centerText('58/3 หมู่ที่ 6 ถ.พระประโทน-บ้านแพ้ว', paperWidth)}
${this.centerText('ต.ตลาดจินดา อ.สามพราน จ.นครปฐม 73110', paperWidth)}
${this.centerText('โทร.(034) 981-555', paperWidth)}
${this.centerText('เลขประจำตัวผู้เสียภาษี 0105563063410', paperWidth)}
${this.centerText('ออกใบกำกับภาษีโดยสำนักงานใหญ่', paperWidth)}
${this.centerText('(บิลเงินสด/ใบกำกับภาษี)', paperWidth)}
${this.centerText('เอกสารออกเป็นชุด', paperWidth)}
${this.leftRightText(
  `รหัสลูกค้า ${data.customer.customercode}`,
  `เลขที่ ${data.saleno}`,
  paperWidth
)}
${this.leftRightText(
  `ชื่อลูกค้า ${this.padThaiText(data.customer.customername, 42)}`,
  `วันที่ ${data.OAORDT}`,
  paperWidth
)}
ที่อยู่ ${data.customer.address1}
${data.customer.address2}
${data.customer.address3} ${data.customer.postCode}
เลขที่ผู้เสียภาษี ${data.customer.taxno}
   
สินค้าที่เปลี่ยนให้ร้านค้า
---------------------------------------------------------------------
รายการสินค้า                        จำนวน    ราคา     ส่วนลด       รวม
`
      const formatItem2 = (no, name, qty, price, discount, total) => {
        const itemQty = this.padThaiText(qty, 7)
        const itemPrice = this.rightText(this.padThaiText(price, 6), 6)
        const itemDiscount = discount.padStart(6)
        const itemTotal = total.padStart(11)

        return `${no} ${this.padThaiText(
          name,
          31
        )} ${itemQty} ${itemPrice} ${itemDiscount} ${itemTotal}`
      }

      const items2 = data.saleItems
        .map((item, index) =>
          formatItem2(
            index + 1,
            item.itemname.replace(' ', '').substring(0, 36),
            item.qtytext,
            parseFloat(item.OBSAPR).toFixed(2).toString(),
            parseFloat(item.disamount).toFixed(2).toString(),
            parseFloat(item.itemamount).toFixed(2).toString()
          )
        )
        .join('\n')

      const totalText2 = thaiNumberToWords(data.saletotaltext)
      const changeText = thaiNumberToWords(data.changeText)
      const footer2 = `    
${this.leftRightText(
  'รวมมูลค่าสินค้า',
  `${parseFloat(data.saleex_vat).toFixed(2)}`,
  '73'
)}
${this.leftRightText('ส่วนลด', '0.00', '70')}
${this.leftRightText(
  'ภาษีมูลค่าเพิ่ม 7%',
  `${parseFloat(data.salevat).toFixed(2)}`,
  '74'
)}
${this.leftRightText(
  'จำนวนเงินรวมสุทธิ',
  `${parseFloat(data.saletotal).toFixed(2)}`,
  paperWidth
)}
${this.rightText(`(${totalText2})`, paperWidth)}
 
${this.leftRightText(
  'ค่าส่วนต่างที่ต้องชำระ',
  `${parseFloat(data.change).toFixed(2)}`,
  '74'
)}
${this.rightText(`(${changeText})`, paperWidth)}
 
${this.leftRightText('', '', '70')}
${this.leftRightText(
  `ผู้รับเงิน ${data.customer.salecode}`,
  '.........................',
  '70'
)}
${this.leftRightText('', 'ลายเซ็นลูกค้า', '63')}
 
 
 
          `

      return header1 + items1 + footer1 + header2 + items2 + footer2
    }
  }
})

const convert = number => {
  const values = [
    '',
    'หนึ่ง',
    'สอง',
    'สาม',
    'สี่',
    'ห้า',
    'หก',
    'เจ็ด',
    'แปด',
    'เก้า'
  ]
  const places = ['', 'สิบ', 'ร้อย', 'พัน', 'หมื่น', 'แสน', 'ล้าน']
  const exceptions = { หนึ่งสิบ: 'สิบ', สองสิบ: 'ยี่สิบ', สิบหนึ่ง: 'สิบเอ็ด' }

  let output = ''

  number
    .toString()
    .split('')
    .reverse()
    .forEach((value, place) => {
      if (place % 6 === 0 && place > 0) {
        output = places[6] + output
      }

      if (value !== '0') {
        output = values[value] + places[place % 6] + output
      }
    })

  for (const [search, replace] of Object.entries(exceptions)) {
    output = output.replace(search, replace)
  }

  return output
}

const thaiNumberToWords = amount => {
  const [integer, fraction] = Math.abs(amount).toFixed(2).split('.')

  const baht = convert(integer)
  const satang = convert(fraction)
  let output = amount < 0 ? 'ลบ' : ''
  output += baht ? baht + 'บาท' : ''
  output += satang ? satang + 'สตางค์' : 'ถ้วน'

  return baht + satang === '' ? 'ศูนย์บาทถ้วน' : output
}
