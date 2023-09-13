/*
Cleaning Data in SQL Queries
*/

SELECT *
FROM NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate, SaleDateConverted, COnvert(Date,Saledate)
FROM NashvilleHousing

Update NashvilleHousing
Set Saledate = Convert(Date,Saledate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date; 

Update NashvilleHousing
Set SaleDateConverted = Convert(Date,Saledate)

--------------------------------------------------------------------------------------------------------------------------------------------------------

-- Popular Property Address Data

SELECT * 
FROM NashvilleHousing
Order By ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------------------------------------
--Breaking out Address into Individual Columns (Address, City, State)

SELECT *
FROM NashvilleHousing
Order By [UniqueID ] 

SELECT PropertyAddress
FROM NashvilleHousing
Order By [UniqueID ] 

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
From NashvilleHousing

ALTER TABLE NashvilleHousing
ADD Property_Address Nvarchar (255)

Update NashvilleHousing
SET Property_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD Property_City Nvarchar (255) 

Update NashvilleHousing
SET Property_City = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-------------

SELECT OwnerAddress
FROM NashvilleHousing
Order By ParcelID

SELECT 
PARSENAME (Replace(OwnerAddress, ',','.'), 3)
,PARSENAME (Replace(OwnerAddress, ',','.'), 2)
,PARSENAME (Replace(OwnerAddress, ',','.'), 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD Owner_Address Nvarchar (255) 

Update NashvilleHousing
SET Owner_Address = PARSENAME (Replace(OwnerAddress, ',','.'), 3)

ALTER TABLE NashvilleHousing
ADD Owner_City Nvarchar (255) 

Update NashvilleHousing
SET Owner_City = PARSENAME (Replace(OwnerAddress, ',','.'), 2)

ALTER TABLE NashvilleHousing
ADD Owner_State Nvarchar (255) 

Update NashvilleHousing
SET Owner_State = PARSENAME (Replace(OwnerAddress, ',','.'), 1)


--------------------------------------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and NO in "Sold as Vacant" field

Select Distinct (SoldAsVacant), COUNT (SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
	END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
	END

--------------------------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE AS( 
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY PARCELID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) AS Row_num
FROM NashvilleHousing
)
DEL ETE
FROM RowNumCTE
WHERE Row_num > 1

--------------------------------------------------------------------------------------------------------------------------------------------------------

-- DELETE Unused Columns

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP Column OWnerAddress, TaxDistrict, PropertyAddress, SaleDate

