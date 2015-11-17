CREATE XML SCHEMA COLLECTION [dbo].[Schema_CompositeArithmeticOperation_Column]
    AS N'<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" elementFormDefault="qualified">
  <xsd:element name="OperationData" type="OperationData" />
  <xsd:complexType name="CompositeOperation">
    <xsd:complexContent>
      <xsd:restriction base="xsd:anyType">
        <xsd:choice minOccurs="2" maxOccurs="2">
          <xsd:sequence>
            <xsd:element name="Function" type="Function" />
          </xsd:sequence>
          <xsd:sequence>
            <xsd:element name="SimpleValue" type="SimpleValue" />
          </xsd:sequence>
          <xsd:sequence>
            <xsd:element name="CompositeOperation" type="CompositeOperation" />
          </xsd:sequence>
        </xsd:choice>
        <xsd:attribute name="Operation" type="OperationEnum" use="required" />
        <xsd:attribute name="Lp" type="LpRange" use="required" />
        <xsd:attribute name="Level" type="xsd:unsignedInt" />
      </xsd:restriction>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name="Function">
    <xsd:complexContent>
      <xsd:restriction base="xsd:anyType">
        <xsd:sequence>
          <xsd:element name="FunctionParameter" type="FunctionParameter" minOccurs="0" maxOccurs="unbounded" />
        </xsd:sequence>
        <xsd:attribute name="Lp" type="LpRange" use="required" />
        <xsd:attribute name="Name" type="ValueString" use="required" />
      </xsd:restriction>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name="FunctionParameter">
    <xsd:complexContent>
      <xsd:restriction base="xsd:anyType">
        <xsd:choice>
          <xsd:sequence>
            <xsd:element name="Scalar" type="Scalar" />
          </xsd:sequence>
          <xsd:sequence>
            <xsd:element name="Relation" type="TargetRelation" />
          </xsd:sequence>
          <xsd:sequence>
            <xsd:element name="Unit" type="TargetUnit" />
          </xsd:sequence>
        </xsd:choice>
        <xsd:attribute name="Name" type="ValueString" use="required" />
      </xsd:restriction>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name="OperationData">
    <xsd:complexContent>
      <xsd:restriction base="xsd:anyType">
        <xsd:sequence>
          <xsd:choice minOccurs="0">
            <xsd:sequence>
              <xsd:element name="Relation" type="TargetRelation" />
            </xsd:sequence>
            <xsd:sequence>
              <xsd:element name="Unit" type="TargetUnit" />
            </xsd:sequence>
          </xsd:choice>
          <xsd:element name="CompositeOperation" type="CompositeOperation" />
        </xsd:sequence>
        <xsd:attribute name="UnitTypeOperationId" type="xsd:int" use="required" />
        <xsd:attribute name="RelationOperationAttributeId" type="xsd:int" use="required" />
        <xsd:attribute name="ValueAttributeTypeId" type="xsd:int" use="required" />
        <xsd:attribute name="UnitTypeValueId" type="xsd:int" use="required" />
      </xsd:restriction>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name="Scalar">
    <xsd:complexContent>
      <xsd:restriction base="xsd:anyType">
        <xsd:sequence />
        <xsd:attribute name="Value" type="ScalarValue" use="required" />
      </xsd:restriction>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name="SimpleValue">
    <xsd:complexContent>
      <xsd:restriction base="xsd:anyType">
        <xsd:choice>
          <xsd:sequence>
            <xsd:element name="Scalar" type="Scalar" />
          </xsd:sequence>
          <xsd:sequence>
            <xsd:element name="Relation" type="TargetRelation" />
          </xsd:sequence>
          <xsd:sequence>
            <xsd:element name="Unit" type="TargetUnit" />
          </xsd:sequence>
        </xsd:choice>
        <xsd:attribute name="Lp" type="LpRange" use="required" />
      </xsd:restriction>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name="TargetRelation">
    <xsd:complexContent>
      <xsd:restriction base="xsd:anyType">
        <xsd:sequence />
        <xsd:attribute name="Id" type="xsd:unsignedInt" use="required" />
        <xsd:attribute name="AttributeTypeId" type="xsd:unsignedInt" use="required" />
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
      </xsd:restriction>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:simpleType name="LpRange">
    <xsd:restriction base="xsd:unsignedInt">
      <xsd:minInclusive value="1" />
      <xsd:maxInclusive value="2" />
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:simpleType name="OperationEnum">
    <xsd:restriction base="xsd:string">
      <xsd:enumeration value="Mul" />
      <xsd:enumeration value="Div" />
      <xsd:enumeration value="Sum" />
      <xsd:enumeration value="Sub" />
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:simpleType name="ScalarValue">
    <xsd:restriction base="xsd:string">
      <xsd:minLength value="1" />
      <xsd:pattern value="[-]?([0-9])+(.([0-9])+)?" />
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:simpleType name="ValueString">
    <xsd:restriction base="xsd:string">
      <xsd:minLength value="1" />
      <xsd:pattern value=".*[^\s].*" />
    </xsd:restriction>
  </xsd:simpleType>
</xsd:schema>';

