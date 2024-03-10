Select * 
From PortfolioProject.dbo.NashvillHousing



---Standardize Date Format

--Select SaleDateConverted, CONVERT(Date,SaleDate)
--From PortfolioProject.dbo.NashvillHousing

Update NashvillHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvillHousing
Add SaleDateConverted Date;

Update NashvillHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-----Populate Property Address data

Select *
From PortfolioProject.dbo.NashvillHousing
--Where PropertyAddress is null
Order by ParcelID


Select a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvillHousing a
JOIN PortfolioProject.dbo.NashvillHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvillHousing a
JOIN PortfolioProject.dbo.NashvillHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null



------Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvillHousing
--Where PropertyAddress is null
--Order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
From PortfolioProject.dbo.NashvillHousing


ALTER TABLE NashvillHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvillHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvillHousing
Add PropertySplitCity Nvarchar(255);

Update NashvillHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.NashvillHousing



Select OwnerAddress
From PortfolioProject.dbo.NashvillHousing

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From PortfolioProject.dbo.NashvillHousing


ALTER TABLE NashvillHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvillHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvillHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvillHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvillHousing
Add OwnerSplitState Nvarchar(255);

Update NashvillHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select *
From PortfolioProject.dbo.NashvillHousing


----Change Y and N to YES and NO in  'Sold as Vacant' field
Select Distinct(SoldAsVacant),Count(SoldAsVacant)
From PortfolioProject.dbo.NashvillHousing
Group By SoldAsVacant
Order By 2

Select SoldAsVacant
,Case When SoldAsVacant = 'Y' Then 'Yes'
	  When SoldAsVacant = 'N' Then 'No'
	  ELSE SoldAsVacant
	  END
From PortfolioProject.dbo.NashvillHousing

Update NashvillHousing 
SET 
SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	  When SoldAsVacant = 'N' Then 'No'
	  ELSE SoldAsVacant
	  END


---Remove Dulicates

WITH RowNumCTE as (
Select *,
	ROW_NUMBER()OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					)row_num

From PortfolioProject.dbo.NashvillHousing
--Order By ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order By PropertyAddress




-----Delete Used Columns

Select *
From PortfolioProject.dbo.NashvillHousing

ALTER TABLE PortfolioProject.dbo.NashvillHousing
DROP COLUMN OwnerAddress, TaxDistrict,PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvillHousing
DROP COLUMN SaleDate
