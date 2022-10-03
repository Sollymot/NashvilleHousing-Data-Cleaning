/*

Cleaning Data in SQL Queries

*/

--Select database to use throughout the data cleaning process
Use [covid portfolio project]

Select * from NashvilleHousing

-----------------------------------------------------------------------------------------------------------------

--Standardized Date Format
Select SaleDate, convert(Date, SaleDate) from NashvilleHousing
--OR
Select SaleDate, cast(SaleDate as Date) from NashvilleHousing


Update NashvilleHousing
Set SaleDate = cast(SaleDate as Date) -- Did not change the column. Let's alter the table to add new column

Alter table NashvilleHousing
add SaleDateConverted Date

Update NashvilleHousing
Set SaleDateConverted = cast(SaleDate as Date)

Select saledateconverted from NashvilleHousing

----------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
Select * from NashvilleHousing
--where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



-- Breaking out Address into individual columns (Address, City, State)
-- Break Property Addredd
select PropertyAddress from NashvilleHousing

--select substring(PropertyAddress, 1) from NashvilleHousing
select 
substring (PropertyAddress, 1, CHARINDEX(',',propertyaddress)-1) as Address,
substring (PropertyAddress, CHARINDEX(',',propertyaddress)+1, LEN(PropertyAddress)) as Address
from NashvilleHousing

Alter table NashvilleHousing
Add PropertySplitAddress Nvarchar(225)

Update NashvilleHousing
SET PropertySplitAddress = substring (PropertyAddress, 1, CHARINDEX(',',propertyaddress)-1)

Alter table NashvilleHousing
Add PropertySplitCity Nvarchar(225)

Update NashvilleHousing
Set PropertySplitCity = substring (PropertyAddress, CHARINDEX(',',propertyaddress)+1, LEN(PropertyAddress))


select * from NashvilleHousing

-- Break Owner's Address
select owneraddress from NashvilleHousing --Use Parsename

Select
PARSENAME(REPLACE(owneraddress, ',', '.'), 3),
PARSENAME(REPLACE(owneraddress, ',', '.'), 2),
PARSENAME(REPLACE(owneraddress, ',', '.'), 1)
from NashvilleHousing

-- Alter table to add separated owners' address
Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(225);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(owneraddress, ',', '.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(225)

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(owneraddress, ',', '.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(225)

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(owneraddress, ',', '.'), 1)

Select * from NashvilleHousing

------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in 'Sold as Vacant Column'
Select distinct(soldasvacant), count(soldasvacant) 
from NashvilleHousing
group by soldasvacant
order by 2;


Select soldasvacant,
	Case when soldasvacant= 'Y' then 'Yes'
		 when soldasvacant= 'N' then 'No'
		 else soldasvacant
		 End
From NashvilleHousing

-- Or
Select soldasvacant,
case when soldasvacant= 'Y' then 'Yes'
	 when soldasvacant= 'N' then 'No'
	 when soldasvacant= 'No' then 'No'
	 when soldasvacant= 'Yes' then 'Yes'
	 else 'unknown'
	 end from NashvilleHousing

--Or
Select soldasvacant,
	case soldasvacant when 'Y' then 'Yes'
					  when 'N' then 'No'
					  when 'Yes' then 'Yes'
					  when 'No' then 'No'
else 'Unknown' End as Dive
From NashvilleHousing


Update NashvilleHousing
Set SoldAsVacant = Case when soldasvacant= 'Y' then 'Yes'
		 when soldasvacant= 'N' then 'No'
		 else soldasvacant
		 End


--------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates 38:46
Select * 
from NashvilleHousing

Select *,
	ROW_NUMBER() over(
	Partition by ParcelID,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From NashvilleHousing
order by ParcelID

--Select row_num greater than 1.... We use CTE to do this
WIth RowNumCTE AS(
Select *,
	ROW_NUMBER() over(
	Partition by ParcelID,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From NashvilleHousing
--order by ParcelID
)
Select * from RowNumCTE
Where row_num >1

--Delete row_num > 1
WIth RowNumCTE AS(
Select *,
	ROW_NUMBER() over(
	Partition by ParcelID,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From NashvilleHousing
--order by ParcelID
)
Delete 
From RowNumCTE
Where row_num >1

---------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns
Select * from NashvilleHousing


Alter Table NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate