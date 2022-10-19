/*

Cleaning data in SQL

*/

--check the dataset
Select *
From PortfolioProject.dbo.Sheet1$

--change date format

Select saleDateConverted, CONVERT(Date,SaleDate)
From  PortfolioProject.dbo.Sheet1$

ALTER TABLE PortfolioProject.dbo.Sheet1$
Add saleDateConverted Date;

Update PortfolioProject.dbo.Sheet1$
SET saleDateConverted = CONVERT(Date,SaleDate)


--populate Property Address data

Select *
From  PortfolioProject.dbo.Sheet1$
--Where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From  PortfolioProject.dbo.Sheet1$ a
JOIN  PortfolioProject.dbo.Sheet1$ b
   ON a.ParcelID = b.ParcelID
   AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From  PortfolioProject.dbo.Sheet1$ a
JOIN  PortfolioProject.dbo.Sheet1$ b
   ON a.ParcelID = b.ParcelID
   AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From  PortfolioProject.dbo.Sheet1$
--Where PropertyAddress is null
--order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1, LEN(PropertyAddress))  as Address
From  PortfolioProject.dbo.Sheet1$

ALTER TABLE PortfolioProject.dbo.Sheet1$
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject.dbo.Sheet1$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1)

ALTER TABLE PortfolioProject.dbo.Sheet1$
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject.dbo.Sheet1$
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1, LEN(PropertyAddress))

--OwnerAddress

Select OwnerAddress
From PortfolioProject.dbo.Sheet1$

Select 
PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 1)
From PortfolioProject.dbo.Sheet1$

ALTER TABLE PortfolioProject.dbo.Sheet1$
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject.dbo.Sheet1$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 3)

ALTER TABLE PortfolioProject.dbo.Sheet1$
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject.dbo.Sheet1$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 2)

ALTER TABLE PortfolioProject.dbo.Sheet1$
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.Sheet1$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 1)

Select *
From PortfolioProject.dbo.Sheet1$

--change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.Sheet1$
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
From PortfolioProject.dbo.Sheet1$


Update PortfolioProject.dbo.Sheet1$
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


--Remove Duplicates

WITH RowNUM AS (
Select *,
   ROW_NUMBER() OVER 
   (PARTITION BY ParcelID,
               PropertyAddress,
			   SaleDate,
			   LegalReference
			   ORDER BY 
			     UniqueID) row_num
From PortfolioProject.dbo.Sheet1$
--Order by ParcelID
)
Select *
From  RowNUM
Where row_num > 1
Order by PropertyAddress

--Delete Unused Columns

ALTER TABLE PortfolioProject.dbo.Sheet1$
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.Sheet1$
DROP COLUMN SaleDate

Select *
From PortfolioProject.dbo.Sheet1$