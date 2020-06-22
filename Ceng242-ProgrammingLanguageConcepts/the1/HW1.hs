module HW1 (
    form,
    constGrid,
    flatten,
    access,
    slice,
    vcat,
    hcat,
    without,
    matches2d
) where

-- do not modify the module declaration above!
-- this will ensure that you cannot load (compile)
-- the module without implementing all of the functions.

-- If you have functions you do not want to implement,
-- leave them as undefined or make them have another
-- default value. If you fully remove any of their definitions,
-- that will be a compilation error during evaluation,
-- and you will be eligible for (yay!) a 5 point deduction
-- (that's bad for your grade). Runtime errors in your code 
-- (rather than compilation errors) are acceptable and will simply
-- result in you getting zero from the specific test case causing
-- an error.

-------------------------
-- Fellowship of the Grid (25, 5, 5, 5 points)

length' :: (Num b) => [a] -> b 
length' [] = 0 
length' xs = sum [1 | _ <- xs]

form :: [a] -> (Int, Int) -> [[a]] 
form result@[] _ = []
form result@[a] _ = [result]
form (arr) (h,w) = bb
 where aa =  take w arr
       dd = drop w arr
       ee = form dd (h,w)
       bb = aa:ee

constGrid :: a -> (Int, Int) -> [[a]]
constGrid a (i, j) = [x | x<-[take j(repeat a)], y<-[1..i]]


flatten :: [[a]] -> [a]
flatten result@[] = []
flatten arr = bb
 where [aa] = take 1 arr
       dd = drop 1 arr
       ee = flatten dd
       bb = aa ++ ee

access :: [[a]] -> (Int, Int) -> a
access arr (i,j) = bb
 where [temp] = take 1 arr
       len = length temp
       aa = flatten arr
       t = i*len + j
       cc = drop t aa
       bb = head cc
----------------------------
-- The Two Signatures (10, 5, 5, 10 points)

slice_helper :: [[a]] -> (Int, Int) -> [[a]]
slice_helper result1@[] _ = []
slice_helper arr (r_start, r_end) = result
 where [fst_row] = take 1 arr
       rest_row = drop 1 arr
       r_diff = r_end-r_start
       aa = drop r_start fst_row
       rows = take r_diff aa
       rest = slice_helper rest_row (r_start, r_end)
       result = rows:rest

slice :: [[a]] -> (Int, Int) -> (Int, Int) -> [[a]]
slice result1@[] _ _ = []
slice arr (c_start,c_end) (r_start, r_end) = result
 where aa = drop c_start arr
       c_diff = c_end-c_start
       columns = take c_diff aa
       result = slice_helper columns (r_start, r_end)

vcat :: [[a]] -> [[a]] -> [[a]]
vcat arr1 arr2 = result
 where result = arr1 ++ arr2

hcat :: [[a]] -> [[a]] -> [[a]]
hcat result1@[] result2@[] = []
hcat [[]] [[]] = [[]]
hcat arr1 arr2 = result
 where [fst_arr1] = take 1 arr1
       rest_arr1 = drop 1 arr1
       [fst_arr2] = take 1 arr2
       rest_arr2 = drop 1 arr2
       fst = fst_arr1++fst_arr2
       rest = hcat rest_arr1 rest_arr2
       result = fst:rest

without_helper :: [[a]] -> (Int, Int) -> [[a]]
without_helper result1@[] _ = []
without_helper arr (r_start, r_end) = result
 where [fst_row] = take 1 arr
       rest_row = drop 1 arr
       fst_row_fst = take r_start fst_row
       fst_row_snd = drop r_end fst_row
       rows = fst_row_fst++fst_row_snd
       rest = without_helper rest_row (r_start, r_end)
       result = rows:rest

without :: [[a]] -> (Int, Int) -> (Int, Int) -> [[a]]
without result1@[] _ _ = []
without arr (c_start,c_end) (r_start, r_end) = result
 where fst = take c_start arr
       snd = drop c_end arr
       columns = fst++snd
       result = without_helper columns (r_start, r_end)
----------------------------
-- Return of the Non-trivial (30 points, 15 subject to runtime constraints)
is_row_match :: Eq a => [[a]] -> [[a]] -> Bool
is_row_match result1@[[]] _ = True
is_row_match result1@[] _ = True
is_row_match _ result1@[[]] = True
is_row_match _ result1@[] = True
is_row_match [rows_tobe] [pattern] = result
  where pattern_row = take 1 pattern
        pattern_rest = drop 1 pattern
        tobe = take 1 rows_tobe
        tobe_rest = drop 1 rows_tobe
        result
         | pattern_row /= tobe = False
         | otherwise = is_row_match [tobe_rest] [pattern_rest]


is_match :: Eq a => [[a]] -> [[a]] -> Int -> Int -> Bool
is_match result1@[[]] _ _ _ = True
is_match result1@[] _ _ _ = True
is_match _ result1@[[]] _ _ = True
is_match _ result1@[] _ _ = True
is_match grid pattern row column
 | row == length grid = False
 | otherwise = result
  where temp_row = drop row grid
        rows_tobe = take 1 temp_row
        pattern_row = take 1 pattern
        temp_pattern = drop 1 pattern
        is_row = is_row_match rows_tobe pattern_row
        result = is_row && is_match grid temp_pattern (row+1) column

matches2d_column_helper :: Eq a => [[a]] -> [[a]] -> [[a]] -> Int -> Int -> [(Int, Int)]
matches2d_column_helper result1@[[]] _ _ _ _ = []
matches2d_column_helper result1@[] _ _ _ _ = []
matches2d_column_helper _ result1@[[]] _ _ _ = []
matches2d_column_helper _ result1@[] _ _ _ = []
matches2d_column_helper _ _ result1@[] _ _ = []
matches2d_column_helper _ _ result1@[[]] _ _ = []
matches2d_column_helper grid pattern [row_rest] row column = result
 where column_element = take 1 row_rest
       col_rest = drop 1 row_rest
       [pattern_temp_element] = take 1 pattern
       pattern_element = take 1 pattern_temp_element
       result
        | column_element /= pattern_element = matches2d_column_helper grid pattern [col_rest] row (column+1)
        | otherwise = result2
         where is = is_match grid pattern row column
               result2
                | is /= True = matches2d_column_helper grid pattern [col_rest] row (column+1)
                | otherwise = [(row, column)]++matches2d_column_helper grid pattern [col_rest] row (column+1)

matches2d_row_helper :: Eq a => [[a]] -> [[a]] -> Int -> Int -> [(Int, Int)]
matches2d_row_helper result1@[[]] _ _ _ = []
matches2d_row_helper result1@[] _ _ _ = []
matches2d_row_helper _ result1@[[]] _ _ = []
matches2d_row_helper _ result1@[] _ _ = []
matches2d_row_helper grid pattern row column = result
 where row_rest = take 1 grid
       rest = drop 1 grid
       result = matches2d_column_helper grid pattern row_rest row column++matches2d_row_helper rest pattern (row+1) column

matches2d :: Eq a => [[a]] -> [[a]] -> [(Int, Int)]
matches2d result1@[[]] _  = []
matches2d _ result1@[[]] = []
matches2d grid pattern
 | length grid < length pattern = []
 | otherwise = matches2d_row_helper grid pattern 0 0
----------------------------
-- What is undefined? Just a value that will cause an error
-- when evaluated, from the GHC implementation:
-- undefined = error "Prelude.undefined"
-- But it allows your module to be compiled
-- since the function definitions will exist.
