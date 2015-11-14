CREATE XML SCHEMA COLLECTION [dbo].[Schema_CalculationA1]
    AS N'<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" elementFormDefault="qualified">
  <xsd:element name="Request">
    <xsd:complexType>
      <xsd:complexContent>
        <xsd:restriction base="xsd:anyType">
          <xsd:sequence>
            <xsd:element name="Dates" type="Dates" minOccurs="0" />
          </xsd:sequence>
          <xsd:attribute name="AppDate" type="datetimeSQL" use="required" />
          <xsd:attribute name="UserId" type="xsd:unsignedInt" use="required" />
          <xsd:attribute name="StructureId" type="xsd:unsignedInt" use="required" />
          <xsd:attribute name="CollectingATId" type="xsd:unsignedInt" use="required" />
          <xsd:attribute name="CollectedATId" type="xsd:unsignedInt" use="required" />
          <xsd:attribute name="Algorithm" type="AlgorithmEnum" use="required" />
          <xsd:attribute name="StatusS" type="xsd:unsignedInt" />
          <xsd:attribute name="StatusP" type="xsd:unsignedInt" />
          <xsd:attribute name="StatusW" type="xsd:unsignedInt" />
          <xsd:attribute name="BranchId" type="xsd:unsignedInt" />
          <xsd:attribute name="RequestType" type="RequestTypeEnum" use="required" />
        </xsd:restriction>
      </xsd:complexContent>
    </xsd:complexType>
  </xsd:element>
  <xsd:complexType name="Dates">
    <xsd:complexContent>
      <xsd:restriction base="xsd:anyType">
        <xsd:sequence />
        <xsd:attribute name="StartDate" type="dateSQL" use="required" />
        <xsd:attribute name="EndDate" type="dateSQL" use="required" />
      </xsd:restriction>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:simpleType name="AlgorithmEnum">
    <xsd:restriction base="xsd:string">
      <xsd:enumeration value="CalculationOfWater" />
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:simpleType name="RequestTypeEnum">
    <xsd:restriction base="xsd:string">
      <xsd:enumeration value="CalculationA1" />
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:simpleType name="dateSQL">
    <xsd:restriction base="xsd:string">
      <xsd:pattern value="((000[1-9])|(00[1-9][0-9])|(0[1-9][0-9]{2})|([1-9][0-9]{3}))-((0[1-9])|(1[012]))-((0[1-9])|([12][0-9])|(3[01]))(Z?)" />
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:simpleType name="datetimeSQL">
    <xsd:restriction base="xsd:string">
      <xsd:pattern value="((000[1-9])|(00[1-9][0-9])|(0[1-9][0-9]{2})|([1-9][0-9]{3}))-((0[1-9])|(1[012]))-((0[1-9])|([12][0-9])|(3[01]))T(([01][0-9])|(2[0-3]))(:[0-5][0-9]){2}(\.[0-9]{1,3})?(Z?)" />
    </xsd:restriction>
  </xsd:simpleType>
</xsd:schema>';

