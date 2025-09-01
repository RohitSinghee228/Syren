

-- Drop new tables in order of dependency to start fresh
DROP TABLE IF EXISTS FactPurchase;
DROP TABLE IF EXISTS FactInventory;
DROP TABLE IF EXISTS FactShipping;
DROP TABLE IF EXISTS FactRecruitment;
DROP TABLE IF EXISTS DimVendor;
DROP TABLE IF EXISTS DimCarrier;
DROP TABLE IF EXISTS DimSalesperson;
DROP TABLE IF EXISTS DimCandidate;
DROP TABLE IF EXISTS DimHiringManager;
DROP TABLE IF EXISTS DimTime;
DROP TABLE IF EXISTS DimStoreAddress;
GO

-- =============================================
-- NEW DIMENSIONS FROM IMAGE
-- =============================================

CREATE TABLE DimVendor (
    VendorKey INT IDENTITY(1,1) PRIMARY KEY,
    VendorID VARCHAR(50) NOT NULL,
    VendorName VARCHAR(100) NOT NULL
);

CREATE TABLE DimCarrier (
    CarrierKey INT IDENTITY(1,1) PRIMARY KEY,
    CarrierID VARCHAR(50) NOT NULL,
    CarrierName VARCHAR(100) NOT NULL
);

CREATE TABLE DimSalesperson (
    SalespersonKey INT IDENTITY(1,1) PRIMARY KEY,
    SalespersonID VARCHAR(50) NOT NULL,
    SalespersonName VARCHAR(255) NOT NULL
);

CREATE TABLE DimCandidate (
    CandidateKey INT IDENTITY(1,1) PRIMARY KEY,
    RecruitmentAddressKey INT,
    CandidateID VARCHAR(50) NOT NULL,
    CandidateName VARCHAR(255) NOT NULL,
    CONSTRAINT FK_Candidate_RecruitmentAddress FOREIGN KEY (RecruitmentAddressKey) REFERENCES DimEmployeeRecruitmentAddress(RecruitmentAddressKey)
);

CREATE TABLE DimHiringManager (
    HiringManagerKey INT IDENTITY(1,1) PRIMARY KEY,
    HiringManagerID VARCHAR(50) NOT NULL,
    HiringManagerName VARCHAR(255) NOT NULL
);

-- The image shows a DimTime table, which is a different grain from DimTimeOfDay
CREATE TABLE DimTime (
    TimeKey INT PRIMARY KEY,
    FullTime TIME NOT NULL,
    HourOfTime TINYINT NOT NULL,
    MinuteOfTime TINYINT NOT NULL
);

CREATE TABLE DimStoreAddress (
    StoreAddressKey INT IDENTITY(1,1) PRIMARY KEY,
    AddressLine1 VARCHAR(255),
    City VARCHAR(100) NOT NULL,
    StateProvince VARCHAR(100) NOT NULL,
    CountryRegion VARCHAR(100) NOT NULL,
    PostalCode VARCHAR(20)
);

-- =============================================
-- NEW FACT TABLES FROM IMAGE
-- =============================================

-- Fact Table for Purchases
CREATE TABLE FactPurchase (
    PurchaseKey INT IDENTITY(1,1) PRIMARY KEY,
    -- Dimension Keys
    DateKey INT NOT NULL,
    TimeKey INT NOT NULL,
    ProductKey INT NOT NULL,
    VendorKey INT NOT NULL,
    -- Degenerate Dimension
    PurchaseOrderNumber VARCHAR(50) NOT NULL,
    -- Measures
    OrderQuantity SMALLINT NOT NULL,
    PurchaseAmount DECIMAL(19, 4) NOT NULL,

    -- Constraints
    CONSTRAINT FK_FactPurchase_DimDate FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey),
    CONSTRAINT FK_FactPurchase_DimTime FOREIGN KEY (TimeKey) REFERENCES DimTime(TimeKey),
    CONSTRAINT FK_FactPurchase_DimProduct FOREIGN KEY (ProductKey) REFERENCES DimProduct(ProductKey),
    CONSTRAINT FK_FactPurchase_DimVendor FOREIGN KEY (VendorKey) REFERENCES DimVendor(VendorKey)
);

-- Fact Table for Inventory
CREATE TABLE FactInventory (
    InventoryKey INT IDENTITY(1,1) PRIMARY KEY,
    -- Dimension Keys
    DateKey INT NOT NULL,
    ProductKey INT NOT NULL,
    StoreKey INT NOT NULL,
    -- Measures
    StockLevel INT NOT NULL,
    InventoryValue DECIMAL(19, 4) NOT NULL,

    -- Constraints
    CONSTRAINT FK_FactInventory_DimDate FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey),
    CONSTRAINT FK_FactInventory_DimProduct FOREIGN KEY (ProductKey) REFERENCES DimProduct(ProductKey),
    CONSTRAINT FK_FactInventory_DimStore FOREIGN KEY (StoreKey) REFERENCES DimStore(StoreKey)
);

-- Fact Table for Shipping
CREATE TABLE FactShipping (
    ShippingKey INT IDENTITY(1,1) PRIMARY KEY,
    -- Dimension Keys
    ShipDateKey INT NOT NULL,
    ProductKey INT NOT NULL,
    CustomerKey INT NOT NULL,
    CarrierKey INT NOT NULL,
    -- Measures
    ShippingCost DECIMAL(19, 4) NOT NULL,
    DeliveryTimeDays SMALLINT NOT NULL,

    -- Constraints
    CONSTRAINT FK_FactShipping_DimDate FOREIGN KEY (ShipDateKey) REFERENCES DimDate(DateKey),
    CONSTRAINT FK_FactShipping_DimProduct FOREIGN KEY (ProductKey) REFERENCES DimProduct(ProductKey),
    CONSTRAINT FK_FactShipping_DimCustomer FOREIGN KEY (CustomerKey) REFERENCES DimCustomer(CustomerKey),
    CONSTRAINT FK_FactShipping_DimCarrier FOREIGN KEY (CarrierKey) REFERENCES DimCarrier(CarrierKey)
);

-- Fact Table for Recruitment
CREATE TABLE FactRecruitment (
    RecruitmentKey INT IDENTITY(1,1) PRIMARY KEY,
    -- Dimension Keys
    DateKey INT NOT NULL,
    CandidateKey INT NOT NULL,
    HiringManagerKey INT NOT NULL,
    -- Measures
    OfferAmount DECIMAL(19, 4) NOT NULL,
    RecruitmentCost DECIMAL(19, 4) NOT NULL,
    
    -- Constraints
    CONSTRAINT FK_FactRecruitment_DimDate FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey),
    CONSTRAINT FK_FactRecruitment_DimCandidate FOREIGN KEY (CandidateKey) REFERENCES DimCandidate(CandidateKey),
    CONSTRAINT FK_FactRecruitment_DimHiringManager FOREIGN KEY (HiringManagerKey) REFERENCES DimHiringManager(HiringManagerKey)
);
