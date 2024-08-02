Create Database TourManagementDBNEW1;
Use TourManagementDBNEW1;

CREATE TABLE Users(ID INT IDENTITY(1,1) PRIMARY KEY, FirstName VARCHAR(100), LastName VARCHAR(100), Password VARCHAR(100),
Email VARCHAR(100), Type VARCHAR(100), Status INT, CreatedOn Datetime);

CREATE TABLE Tours(ID INT IDENTITY(1,1) PRIMARY KEY, Name VARCHAR(100), Location VARCHAR(100), Price VARCHAR(100),
Status INT, CreatedOn Datetime);

CREATE TABLE Bookings(ID INT IDENTITY(1,1) PRIMARY KEY, UserID INT, TourID INT, BookingDate VARCHAR(100));

INSERT INTO Users(FirstName, LastName, Email, Password, Type,Status,CreatedOn)
VALUES('admin','admin','admin','admin','admin',1,GETDATE())

SELECT * FROM Users;
SELECT * FROM Tours;
SELECT * FROM Bookings;


CREATE PROC sp_register(@ID INT = NULL, @FirstName VARCHAR(100) = NULL, @LastName VARCHAR(100) = NULL, @Password VARCHAR(100) = NULL,
@Email VARCHAR(100) = NULL, @Type VARCHAR(100) = NULL, @Status INT = NULL, @ActionType VARCHAR(100) = NULL)
AS
BEGIN
	IF @Type = 'Add'
	BEGIN
		INSERT INTO Users(FirstName,LastName,Password,Email,Type,Status,CreatedOn)
		VALUES(@FirstName,@LastName,@Password,@Email,@Type,1,GETDATE())
	END	
END;

CREATE PROC sp_login(@Email VARCHAR(100), @Password VARCHAR(100))
AS
BEGIN
	SELECT * FROM Users WHERE Email = @Email AND Password = @Password AND Status = 1;
END;

CREATE PROC sp_viewUser(@ID INT = null, @Email VARCHAR(100) = null)
AS
BEGIN
	IF @ID IS NOT null AND @ID != 0
	BEGIN
		SELECT * FROM Users WHERE ID = @ID AND Status = 1;
	END
	IF @Email IS NOT null AND @Email != ''
	BEGIN
		SELECT * FROM Users WHERE Email = @Email AND Status = 1;
	END
END;

CREATE PROC sp_Tour(@ID INT = NULL, @Name VARCHAR(100)=NULL, @Location VARCHAR(100)=NULL, @Price VARCHAR(100)=NULL,
@Type VARCHAR(10))
AS
BEGIN
	IF @Type = 'ADD'
	BEGIN
		INSERT INTO Tours VALUES(@Name,@Location,@Price,1,GETDATE());
	END
	IF @Type = 'Update'
	BEGIN
		UPDATE Tours SET Name =CASE WHEN @Name != '' AND @Name IS NOT NULL THEN @Name ELSE Name END, 
		Location = CASE WHEN @Location != '' AND @Location IS NOT NULL THEN @Location ELSE Location END, 
		Price =  CASE WHEN @Price != '' AND @Price IS NOT NULL THEN @Price ELSE Price END
		WHERE ID = @ID AND Status = 1;
	END
	IF @Type = 'DELETE'
	BEGIN
		UPDATE Tours SET Status = 0 WHERE ID = @ID;
	END
	IF @Type = 'GETALL'
	BEGIN
		SELECT * FROM Tours WHERE Status = 1;
	END
	IF @Type = 'ADD'
	BEGIN
		SELECT * FROM Tours WHERE Status = 1 AND ID = @ID;
	END
END

CREATE PROC [dbo].[sp_Bookings](@ID INT = NULL, @UserID INT = NULL, @TourID INT = NULL, @BookingDate VARCHAR(100) = NULL, @Type VARCHAR(10))  
AS  
BEGIN  
 IF @Type = 'ADD'  
 BEGIN  
  INSERT INTO Bookings VALUES(@UserID, @TourID, @BookingDate);  
    END  
 IF @Type = 'GET' AND  @UserID != 0
 BEGIN  
  SELECT B.ID, T.Name AS TourName, CONCAT(U.FirstName,' ',U.LastName)  AS UserName, T.Location, T.Price, B.BookingDate 
  FROM Bookings B 
  INNER JOIN Tours T ON B.TourID = T.ID
  INNER JOIN Users U ON U.ID = B.UserID
  WHERE B.UserID = @UserID 
  AND T.Status = 1;  
 END
 IF @Type = 'GET' AND  @UserID = 0
 BEGIN  
  
  SELECT B.ID, T.Name AS TourName, CONCAT(U.FirstName,' ',U.LastName)  AS UserName, T.Location, T.Price, B.BookingDate 
  FROM Bookings B 
  INNER JOIN Tours T ON B.TourID = T.ID
  INNER JOIN Users U ON U.ID = B.UserID
  WHERE  T.Status = 1;

 END
END; 


ALTER TABLE Bookings ADD TotalPeople VARCHAR(100);
ALTER PROC [dbo].[sp_Bookings](@ID INT = NULL, @UserID INT = NULL, @TourID INT = NULL, @BookingDate VARCHAR(100) = NULL, @Type VARCHAR(10),
@TotalPeople VARCHAR(100) = NULL)    
AS    
BEGIN    
 IF @Type = 'ADD'    
 BEGIN    
  INSERT INTO Bookings VALUES(@UserID, @TourID, @BookingDate, @TotalPeople);    
    END    
 IF @Type = 'GET' AND  @UserID != 0  
 BEGIN    
  SELECT B.ID, T.Name AS TourName, CONCAT(U.FirstName,' ',U.LastName)  AS UserName, T.Location, T.Price, B.BookingDate, B.TotalPeople 
  FROM Bookings B   
  INNER JOIN Tours T ON B.TourID = T.ID  
  INNER JOIN Users U ON U.ID = B.UserID  
  WHERE B.UserID = @UserID   
  AND T.Status = 1;    
 END  
 IF @Type = 'GET' AND  @UserID = 0  
 BEGIN        
  SELECT B.ID, T.Name AS TourName, CONCAT(U.FirstName,' ',U.LastName)  AS UserName, T.Location, T.Price, B.BookingDate, B.TotalPeople    
  FROM Bookings B   
  INNER JOIN Tours T ON B.TourID = T.ID  
  INNER JOIN Users U ON U.ID = B.UserID  
  WHERE  T.Status = 1;    
 END  
 IF @Type = 'DELETE'    
 BEGIN    
  DELETE FROM Bookings WHERE Id = @ID;
 END 
END;


ALTER TABLE Bookings ADD Status INT;

ALTER PROC [dbo].[sp_Bookings](@ID INT = NULL, @UserID INT = NULL, @TourID INT = NULL, @BookingDate VARCHAR(100) = NULL, @Type VARCHAR(10),  
@TotalPeople VARCHAR(100) = NULL)      
AS      
BEGIN      
 IF @Type = 'ADD'      
 BEGIN      
  INSERT INTO Bookings VALUES(@UserID, @TourID, @BookingDate, @TotalPeople,1);      
    END      
 IF @Type = 'GET' AND  @UserID != 0    
 BEGIN      
  SELECT B.ID, T.Name AS TourName, CONCAT(U.FirstName,' ',U.LastName)  AS UserName, T.Location, T.Price, 
  CONVERT(VARCHAR(30), CAST (B.BookingDate AS DATE), 103 ) AS BookingDate, B.TotalPeople, U.Email, 
  ISNULL(B.Status,1) AS Status      
  FROM Bookings B     
  INNER JOIN Tours T ON B.TourID = T.ID    
  INNER JOIN Users U ON U.ID = B.UserID    
  WHERE B.UserID = @UserID     
  AND T.Status = 1;      
 END    
 IF @Type = 'GET' AND  @UserID = 0    
 BEGIN          
  SELECT B.ID, T.Name AS TourName, CONCAT(U.FirstName,' ',U.LastName)  AS UserName,
  U.Email,
  T.Location, T.Price,
  CONVERT(VARCHAR(30), CAST (B.BookingDate AS DATE), 103 ) AS BookingDate, B.BookingDate, B.TotalPeople, U.Email, 
  ISNULL(B.Status,1) AS Status      
  FROM Bookings B     
  INNER JOIN Tours T ON B.TourID = T.ID    
  INNER JOIN Users U ON U.ID = B.UserID    
  WHERE  T.Status = 1;      
 END    
 IF @Type = 'DELETE'      
 BEGIN      
 --DELETE FROM Bookings WHERE Id = @ID;  

 UPDATE Bookings SET Status = 0 WHERE Id = @ID; 
 END   
END;


delete  from bookings where status=0