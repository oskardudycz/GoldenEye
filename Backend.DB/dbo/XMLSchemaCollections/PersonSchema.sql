CREATE XML SCHEMA COLLECTION [dbo].[PersonSchema]
    AS N'<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <xsd:element name="Employee">
    <xsd:complexType>
      <xsd:complexContent>
        <xsd:restriction base="xsd:anyType">
          <xsd:sequence>
            <xsd:element name="FirstName" type="xsd:anyType" />
            <xsd:element name="LastName" type="xsd:anyType" />
            <xsd:element name="Age" type="xsd:anyType" />
          </xsd:sequence>
        </xsd:restriction>
      </xsd:complexContent>
    </xsd:complexType>
  </xsd:element>
</xsd:schema>';

