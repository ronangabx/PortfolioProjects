Select *
From housing.dbo.Nashville


-- Standardize DATE Format
Select SaleDate
From housing.dbo.Nashville

ALTER TABLE Nashville
ADD SaleDateConverted Date;

UPDATE Nashville
SET SaleDateConverted = CONVERT(date,SaleDate)



-- Populate Property Address Data by referencing duplicate ParcelDs and Updating Null Values in the table.

Select original.ParcelID, original.PropertyAddress, reference.ParcelID, reference.PropertyAddress,
		ISNULL( original.PropertyAddress,reference.PropertyAddress)
From housing.dbo.Nashville original
JOIN housing.dbo.Nashville reference
	ON original.ParcelID = reference.ParcelID
	AND original.[UniqueID] <> reference.[UniqueID]
Where original.PropertyAddress is NULL

Update original
SET PropertyAddress = ISNULL( original.PropertyAddress,reference.PropertyAddress)
From housing.dbo.Nashville original
JOIN housing.dbo.Nashville reference
	ON original.ParcelID = reference.ParcelID
	AND original.[UniqueID] <> reference.[UniqueID]
Where original.PropertyAddress is NULL



-- Separating Property Address Details (Street, City)
Select PropertyAddress
From housing.dbo.Nashville

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
From housing.dbo.Nashville

ALTER TABLE Nashville
ADD PropertyStreetAddress nvarchar(255);

UPDATE Nashville
SET PropertyStreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE Nashville
ADD PropertyCity nvarchar(255);

UPDATE Nashville
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


-- Separating Owner Address Details (Street, City, State)
Select OwnerAddress
From housing.dbo.Nashville

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From housing.dbo.Nashville

ALTER TABLE Nashville
ADD OwnerStreetAddress nvarchar(255);

UPDATE Nashville
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Nashville
ADD OwnerCity nvarchar(255);

UPDATE Nashville
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Nashville
ADD OwnerState nvarchar(255);

UPDATE Nashville
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)




-- Make data uniformed in SoldAsVacant Column. Make it all "Yes" or "No"
Select Distinct(SoldAsVacant), Count(SoldAsVacant) as Frequency
From housing.dbo.Nashville
Group By SoldAsVacant
Order By 2

Select SoldAsVacant,
CASE 
	When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
END
From housing.dbo.Nashville

UPDATE Nashville
SET SoldAsVacant =
CASE 
	When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
END



-- Removing Duplicates
WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
				) row_num
From housing.dbo.Nashville
)
DELETE
From RowNumCTE
Where row_num > 1



--- Delete Unused Columns
Select *
From housing.dbo.Nashville

ALTER TABLE housing.dbo.Nashville
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate 
