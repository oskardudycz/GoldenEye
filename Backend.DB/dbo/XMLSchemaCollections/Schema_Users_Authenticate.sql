CREATE XML SCHEMA COLLECTION [dbo].[Schema_Users_Authenticate]
    AS N'<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" elementFormDefault="qualified">
  <xsd:element name="Request">
    <xsd:complexType>
      <xsd:complexContent>
        <xsd:restriction base="xsd:anyType">
          <xsd:all>
            <xsd:element name="Credentials">
              <xsd:complexType>
                <xsd:complexContent>
                  <xsd:restriction base="xsd:anyType">
                    <xsd:sequence />
                    <xsd:attribute name="Login" type="xsd:string" use="required" />
                    <xsd:attribute name="Password" type="xsd:string" use="required" />
                  </xsd:restriction>
                </xsd:complexContent>
              </xsd:complexType>
            </xsd:element>
          </xsd:all>
          <xsd:attribute name="RequestType" type="xsd:string" fixed="Users_Authenticate" />
          <xsd:attribute name="AppDate" type="xsd:date" />
        </xsd:restriction>
      </xsd:complexContent>
    </xsd:complexType>
  </xsd:element>
</xsd:schema>';

