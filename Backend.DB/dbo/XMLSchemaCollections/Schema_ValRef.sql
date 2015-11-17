CREATE XML SCHEMA COLLECTION [dbo].[Schema_ValRef]
    AS N'<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <xsd:element name="Relation" type="TargetRelation" />
  <xsd:element name="Unit" type="TargetUnit" />
  <xsd:complexType name="TargetRelation">
    <xsd:complexContent>
      <xsd:restriction base="xsd:anyType">
        <xsd:sequence />
        <xsd:attribute name="Id" type="xsd:unsignedInt" use="required" />
        <xsd:attribute name="AttributeTypeId" type="xsd:unsignedInt" use="required" />
        <xsd:attribute name="Date" type="datetimeSQL" />
      </xsd:restriction>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name="TargetUnit">
    <xsd:complexContent>
      <xsd:restriction base="xsd:anyType">
        <xsd:sequence />
        <xsd:attribute name="Id" type="xsd:unsignedInt" use="required" />
        <xsd:attribute name="TypeId" type="xsd:unsignedInt" use="required" />
        <xsd:attribute name="AttributeTypeId" type="xsd:unsignedInt" use="required" />
        <xsd:attribute name="Date" type="datetimeSQL" />
      </xsd:restriction>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:simpleType name="datetimeSQL">
    <xsd:restriction base="xsd:string">
      <xsd:pattern value="((000[1-9])|(00[1-9][0-9])|(0[1-9][0-9]{2})|([1-9][0-9]{3}))-((0[1-9])|(1[012]))-((0[1-9])|([12][0-9])|(3[01]))T(([01][0-9])|(2[0-3]))(:[0-5][0-9]){2}(\.[0-9]{1,3})?(Z?)" />
    </xsd:restriction>
  </xsd:simpleType>
</xsd:schema>';

