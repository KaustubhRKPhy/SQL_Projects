-- Cleaning Data in SQL

Select *
From NashvilleHousing

-- Standardising date format 

Select SaleDate, CONVERT(Date, SaleDate)
From NashvilleHousing

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDateConverted
From NashvilleHousing

-- Populate property address data

Select *
From NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IsNull(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = IsNull(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking address into individual columns such as Address, City, State

Select PropertyAddress
From NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
From NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) 

Select PropertySplitAddress, PropertySplitCity
From NashvilleHousing

Select OwnerAddress
From NashvilleHousing

Select 
Parsename(Replace(OwnerAddress, ',', '.'), 3),
Parsename(Replace(OwnerAddress, ',', '.'), 2),
Parsename(Replace(OwnerAddress, ',', '.'), 1)
From NashvilleHousing

Alter Table NashvilleHousing
Add OwnerAddressSplitStreet nvarchar(255);

Update NashvilleHousing
Set OwnerAddressSplitStreet = Parsename(Replace(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing
Add OwnerAddressSplitCity nvarchar(255);

Update NashvilleHousing
Set OwnerAddressSplitCity = Parsename(Replace(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
Add OwnerAddressSplitState nvarchar(255);

Update NashvilleHousing
Set OwnerAddressSplitState = Parsename(Replace(OwnerAddress, ',', '.'), 1)

Select OwnerAddressSplitStreet, OwnerAddressSplitCity, OwnerAddressSplitState 
From NashvilleHousing

-- Change Y and N to Yes and No in 'Sold as Vacant' field

Select SoldAsVacant,
CASE 
    When SoldAsVacant = 'Y' then 'Yes'
    When SoldAsVacant = 'N' then 'No'
    Else SoldAsVacant
END
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = CASE 
    When SoldAsVacant = 'Y' then 'Yes'
    When SoldAsVacant = 'N' then 'No'
    Else SoldAsVacant
END

Select SoldAsVacant
From NashvilleHousing

-- Remove Duplicates 

WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
                         PropertyAddress, 
                         SalePrice,
                         SaleDate,
                         LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM NashvilleHousing
)
SELECT *
FROM RowNumCTE
Where row_num > 1

-- Delete the duplicates 
WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
                         PropertyAddress, 
                         SalePrice,
                         SaleDate,
                         LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM NashvilleHousing
)
Delete
FROM RowNumCTE
Where row_num > 1

-- Checking if duplicates have been removed 
WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
                         PropertyAddress, 
                         SalePrice,
                         SaleDate,
                         LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM NashvilleHousing
)
SELECT *
FROM RowNumCTE
Where row_num > 1

-- Removing unnecessary columns 

Select *
From NashvilleHousing

Alter Table NashvilleHousing
Drop Column PropertyAddress, TaxDistrict, OwnerAddress

Alter Table NashvilleHousing
Drop Column SaleDate

-- Showing the edited dataset 

Select *
From NashvilleHousing
