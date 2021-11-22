set design "cpu"
set top "${design}_wrapper"
set proj_dir "./ip_proj"

set ip_properties [ list \
    vendor "nealcrawford.com" \
    library "CPU" \
    name ${design} \
    version "1.0" \
    taxonomy "/CPU_Files" \
    display_name "16-Bit CPU" \
    description "SAP style 16 Bit CPU" \
    vendor_display_name "Neal Crawford" \
    company_url "http://nealcrawford.com" \
    ]

set family_lifecycle { \
  artix7 Production \
  artix7l Production \
  kintex7 Production \
  kintex7l Production \
  kintexu Production \
  kintexuplus Production \
  zynq Production \
  zynquplus Production \
  aartix7 Production \
  azynq Production \
}