BusinessAssociate.create!(
    admin_f_name: 'AdminFName',
    admin_l_name: 'AdminLName',
    name: 'BusinessAssociateName',
    pan: Devise.friendly_token.first(10),
    tan: Devise.friendly_token.first(10),
    legal_name: 'BA Legal Name',
    service_tax_no: Devise.friendly_token.first(15),
    hq_address: '#2, 2ND CROSS, GHATTA GAON, NEAR LIC BUILDING, GURGAON, HARYANA, 122002'
)