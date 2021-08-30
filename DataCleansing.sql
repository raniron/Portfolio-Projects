

--Cleansing data in SQL

 

-- Standardise Date Format

Alter table FutureHousing

Add FormattedSaleDate Date

Update FutureHousing

Set FormattedSaleDate = Convert(Date,SaleDate)

--- How to convert dateformat to UK 

Select format(FormattedSaleDate,'dd/MM/yyyy')  from FutureHousing


--Populate Property Address data


Select *

From PortfolioProject01.dbo.FutureHousing
Where PropertyAddress IS NULL
order by ParcelID
  --Finding NUll valued PropertyAddress and updating with the Property Address of the same ParcellID and Different Unique ID
Select a.ParcelID, ISNULL(a.PropertyAddress,b.PropertyAddress), b.ParcelID, b.PropertyAddress
From PortfolioProject01.dbo.FutureHousing a
JOIN PortfolioProject01.dbo.FutureHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject01.dbo.FutureHousing a
JOIN PortfolioProject01.dbo.FutureHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Splitting Address

Select 

Substring (PropertyAddress,1,Charindex(',',PropertyAddress)-1) as PropertyAddress1

From PortfolioProject01.dbo.FutureHousing

Select 

Substring (PropertyAddress,Charindex(',',PropertyAddress)+1,Len(PropertyAddress)) as PropertyAddress2

From PortfolioProject01.dbo.FutureHousing



Alter table FutureHousing

Add PropertyAddress1 nvarchar(255)

Update FutureHousing

Set PropertyAddress1 = Substring (PropertyAddress,1,Charindex(',',PropertyAddress)-1) 

Alter table FutureHousing

Add PropertyAddress2 nvarchar(255)

Update FutureHousing

Set PropertyAddress2 = Substring (PropertyAddress,Charindex(',',PropertyAddress)+1,Len(PropertyAddress))



Select * From PortfolioProject01..FutureHousing


--Splitting OwnerAddress

Select

PARSENAME(Replace(OwnerAddress,',','.'),3)as StreetAddress,
PARSENAME(Replace(OwnerAddress,',','.'),2)as City ,
PARSENAME(Replace(OwnerAddress,',','.'),1)as Postcode

From PortfolioProject01..FutureHousing


Alter table FutureHousing

Add OwnerPostcode nvarchar(255)

Update FutureHousing

Set OwnerPostcode = PARSENAME(Replace(OwnerAddress,',','.'),1)

Alter table FutureHousing

Add OwnerCity nvarchar(255)

Update FutureHousing

Set OwnerCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

Alter table FutureHousing

Add OwnerStreetAddress nvarchar(255)

Update FutureHousing

Set OwnerStreetAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)


Select * From PortfolioProject01..FutureHousing

--Change Y to Yes and  N to No in "Sold as Vacant" field

Select Distinct(SoldAsVacant),Count(SoldAsVacant)as TotalNo
From PortfolioProject01..FutureHousing
Group by SoldAsVacant
Order by TotalNo

Update FutureHousing

Set SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
                        When SoldAsVacant = 'N' THEN 'No'
				        ELSE SoldAsVacant
						END

--Finding Duplicates

With ROWNUMCTE (ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference,RowNum)

AS(
Select ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject01..FutureHousing)

Select * 

From ROWNUMCTE

Where RowNum >1
 
 --Removing Duplicate

 With ROWNUMCTE (ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference,RowNum)

AS(
Select ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject01..FutureHousing)

DELETE

From ROWNUMCTE

Where RowNum >1

--Delete Unused Columns

Select * From PortfolioProject01..FutureHousing

Alter Table PortfolioProject01..FutureHousing

DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate