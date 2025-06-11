//%attributes = {}
var $catalog : cs:C1710.Catalog
$catalog:=cs:C1710.Catalog.new()

$relations:=$catalog.get1toN("Table_1"; "Field_2")  //1toN relations to this field
$relations:=$catalog.getNto1("Table_3"; "Field_2")  //Nto1 relations from this field