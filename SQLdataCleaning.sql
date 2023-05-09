--cleaning data in SQL queries

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


---Standardize date format

SELECT SaleDateConverted,CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE	NashvilleHousing
SET SaleDateConverted =CONVERT(Date, SaleDate)

--Populate Property Address data

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null
order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

update a
set PropertyAddress =  ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


--Breaking out Address into Individual Columns (address, city, state)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))as Address

FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE	NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE	NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',' ,'.') ,3)
,PARSENAME(REPLACE(OwnerAddress,',' ,'.') ,2)
,PARSENAME(REPLACE(OwnerAddress,',' ,'.') ,1)
FROM PortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE	NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',' ,'.') ,3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE	NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',' ,'.') ,2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE	NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',' ,'.') ,1)


--Change Y to Yes and  N in "sold as Vacant" field

SELECT distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
,CASE When SoldAsVacant ='Y' then 'YES'
     when SoldAsVacant = 'N' then 'NO'
   else SoldAsVacant
   END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant ='Y' then 'YES'
     when SoldAsVacant = 'N' then 'NO'
   else SoldAsVacant
   END

   --Remove Duplicates---not common practice in SQL

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() over(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num


FROM PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
select * -- use delete to erase the duplicates
from RowNumCTE
Where row_num > 1
--order by PropertyAddress

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


--Delete unused columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing



ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress



ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate