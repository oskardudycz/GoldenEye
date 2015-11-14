CREATE XML SCHEMA COLLECTION [dbo].[Schema_SimpleOperationBase]
    AS N'<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <xsd:element name="Request" type="Request_SimpleOperation" />
  <xsd:attributeGroup name="BaseRequest_AG">
    <xsd:attribute name="BranchId" type="xsd:unsignedInt" />
    <xsd:attribute name="UserId" type="xsd:unsignedInt" use="required" />
    <xsd:attribute name="AppDate" type="datetimeSQL" use="required" />
    <xsd:attribute name="StatusS" type="xsd:unsignedInt" />
    <xsd:attribute name="StatusP" type="xsd:unsignedInt" />
    <xsd:attribute name="StatusW" type="xsd:unsignedInt" />
  </xsd:attributeGroup>
  <xsd:complexType name="Relation">
    <xsd:complexContent>
      <xsd:restriction base="xsd:anyType">
        <xsd:sequence />
        <xsd:attribute name="Lp" type="LpRange" use="required" />
        <xsd:attribute name="Id" type="xsd:unsignedInt" use="required" />
        <xsd:attribute name="AttributeTypeId" type="xsd:unsignedInt" use="required" />
      </xsd:restriction>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name="Request_SimpleOperation">
    <xsd:complexContent>
      <xsd:restriction base="xsd:anyType">
        <xsd:choice minOccurs="2" maxOccurs="2">
          <xsd:sequence>
            <xsd:element name="Scalar" type="Scalar" />
          </xsd:sequence>
          <xsd:sequence>
            <xsd:element name="Relation" type="Relation" />
          </xsd:sequence>
          <xsd:sequence>
            <xsd:element name="Unit" type="Unit" />
          </xsd:sequence>
        </xsd:choice>
        <xsd:attributeGroup ref="BaseRequest_AG" />
      </xsd:restriction>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name="Scalar">
    <xsd:complexContent>
      <xsd:restriction base="xsd:anyType">
        <xsd:sequence />
        <xsd:attribute name="Lp" type="LpRange" use="required" />
        <xsd:attribute name="Value" type="ValueString" use="required" />
      </xsd:restriction>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name="Unit">
    <xsd:complexContent>
      <xsd:restriction base="xsd:anyType">
        <xsd:sequence />
        <xsd:attribute name="Lp" type="LpRange" use="required" />
        <xsd:attribute name="Id" type="xsd:unsignedInt" use="required" />
        <xsd:attribute name="TypeId" type="xsd:unsignedInt" use="required" />
        <xsd:attribute name="AttributeTypeId" type="xsd:unsignedInt" use="required" />
      </xsd:restriction>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:simpleType name="LpRange">
    <xsd:restriction base="xsd:unsignedInt">
      <xsd:minInclusive value="1" />
      <xsd:maxInclusive value="2" />
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:simpleType name="ValueString">
    <xsd:restriction base="xsd:string">
      <xsd:minLength value="1" />
      <xsd:pattern value=".*[^\s].*" />
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:simpleType name="datetimeSQL">
    <xsd:restriction base="xsd:string">
      <xsd:pattern value="((000[1-9])|(00[1-9][0-9])|(0[1-9][0-9]{2})|([1-9][0-9]{3}))-((0[1-9])|(1[012]))-((0[1-9])|([12][0-9])|(3[01]))T(([01][0-9])|(2[0-3]))(:[0-5][0-9]){2}(\.[0-9]{1,3})?(Z?)" />
    </xsd:restriction>
  </xsd:simpleType>
</xsd:schema>';

