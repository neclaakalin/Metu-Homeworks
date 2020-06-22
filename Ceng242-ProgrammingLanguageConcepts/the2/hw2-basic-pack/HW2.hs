module HW2 (
    parse, -- reexport for easy terminal use
    foldAndPropagateConstants,
    assignCommonSubexprs,
    reducePoly
) where

import Expression
import Parser
import Data.List
import Data.Char
import qualified Data.List as L
import Data.Monoid
import Data.Ord

-- Do not change the module definition and imports above! Feel free
-- to modify the parser, but please remember that it is just a helper
-- module and is not related to your grade. You should only submit
-- this file. Feel free to import other modules, especially Data.List!

data VarData = Exists String Int

calculate_expr :: [ExprV] -> [VarData] -> ExprV
calculate_expr [Leaf (Constant d)] _ = Leaf (Constant d)
calculate_expr [Leaf (Variable d)] [] = Leaf (Variable d)
calculate_expr [Leaf (Variable d)] varray = result
 where is_constant = is_constantleaf [Leaf (Variable d)] varray
       result = 
        if is_constant == False
         then Leaf (Variable d)
        else Leaf (Constant (constant_expr [Leaf (Variable d)] varray))
calculate_expr [UnaryOperation Minus (expr)] varray = result
 where is_constant = is_constantleaf [expr] varray
       result = 
        if is_constant == False
         then UnaryOperation Minus (calculate_expr [expr] varray)
         else result_true
            where c = (-1)*constant_expr [expr] varray
                  result_true = Leaf (Constant c)
calculate_expr [BinaryOperation Plus (expr1) (expr2)] varray = result
 where is_constant = is_constantleaf [expr1] varray && is_constantleaf [expr2] varray
       result = 
        if is_constant == False
         then BinaryOperation Plus (calculate_expr [expr1] varray) (calculate_expr [expr2] varray)
         else Leaf (Constant (constant_expr [calculate_expr [expr1] varray] varray + constant_expr [calculate_expr [expr2] varray] varray))
calculate_expr [BinaryOperation Times (expr1) (expr2)] varray = result
 where is_constant = is_constantleaf [expr1] varray && is_constantleaf [expr2] varray
       result = 
        if is_constant == False
         then BinaryOperation Times (calculate_expr [expr1] varray) (calculate_expr [expr2] varray)
         else Leaf (Constant (constant_expr [calculate_expr [expr1] varray] varray * constant_expr [calculate_expr [expr2] varray] varray))

is_var_in :: String -> [VarData] -> Bool
is_var_in d [Exists var value] = (var == d)

is_constantleaf :: [ExprV] -> [VarData] -> Bool
is_constantleaf [Leaf (Constant d)] _ = True
is_constantleaf [Leaf (Variable d)] [] = False
is_constantleaf [Leaf (Variable d)] varray = result
 where frst = take 1 varray
       rest = drop 1 varray
       is_frst = is_var_in d frst
       result = 
        if is_frst == True 
         then True
         else is_constantleaf [Leaf (Variable d)] rest
is_constantleaf [BinaryOperation Plus (expr1) (expr2)] varray = is_constantleaf [expr1] varray && is_constantleaf [expr2] varray
is_constantleaf [BinaryOperation Times (expr1) (expr2)] varray = is_constantleaf [expr1] varray && is_constantleaf [expr2] varray
is_constantleaf [UnaryOperation Minus (expr1)] varray = is_constantleaf [expr1] varray
is_constantleaf _ _ = False

take_frst_value :: String -> [VarData] -> Int
take_frst_value d [Exists var value] = value

constant_expr :: [ExprV] -> [VarData] -> Int
constant_expr [Leaf (Constant d)] _ = d
constant_expr [Leaf (Variable d)] varray = result
 where frst = take 1 varray
       rest = drop 1 varray
       is_frst = is_var_in d frst
       result = 
        if is_frst == False
         then constant_expr [Leaf (Variable d)] rest
        else take_frst_value d frst

foldAndPropagateConstants_helper :: [(String, ExprV)] -> [VarData] -> [(String, ExprV)]
foldAndPropagateConstants_helper result1@[] _ = []
foldAndPropagateConstants_helper equations varray = result
 where [(var, expr)] = take 1 equations
       rest_equations = drop 1 equations
       calculated_expr = calculate_expr [expr] varray
       is_constant = is_constantleaf [calculated_expr] varray
       result =
        if is_constant == False
         then [(var, calculated_expr)] ++ foldAndPropagateConstants_helper rest_equations varray
         else result_true
             where varray2 = varray ++ [Exists var (constant_expr [calculated_expr] varray)]
                   result_true = [(var, calculated_expr)] ++ foldAndPropagateConstants_helper rest_equations varray2

foldAndPropagateConstants :: [(String, ExprV)] -> [(String, ExprV)]
foldAndPropagateConstants result1@[] = []
foldAndPropagateConstants equations = foldAndPropagateConstants_helper equations []

---------------------------------------------------------------------------------------------------------------------

data SubExpressions = Sub String ExprV

is_subLeaf :: [ExprV] -> [SubExpressions] -> Bool
is_subLeaf [Leaf (Constant d)] _ = True
is_subLeaf [Leaf (Variable d)] _ = True
is_subLeaf _ _ = False

is_subExpression_in :: [ExprV] -> [SubExpressions] -> Bool
is_subExpression_in _ [] = False
is_subExpression_in [expr1] sarray = result
 where [(Sub var expr2)] = take 1 sarray
       rest = drop 1 sarray
       result = 
        if expr1 == expr2
         then True
        else is_subExpression_in [expr1] rest

get_subVar :: [ExprV] -> [SubExpressions] -> String
get_subVar [expr1] sarray = result
 where [(Sub var expr2)] = take 1 sarray
       rest = drop 1 sarray
       result = 
        if expr1 == expr2
         then var
        else get_subVar [expr1] rest

get_where_1 :: [ExprV] -> [ExprV] -> [SubExpressions] -> Int -> (ExprV, [SubExpressions], Int)
get_where_1 [expr1] [expr2] sarray i = result
 where (expr, sarray, i) = simplify expr2 sarray i
       result = ((BinaryOperation Plus (Leaf (Variable (get_subVar [expr1] sarray))) (expr)), sarray, i)

get_where_2 :: ExprV -> ExprV -> [SubExpressions] -> Int -> (ExprV, [SubExpressions], Int)
get_where_2 expr1 expr2 sarray i = result
 where (expr, sarray, i) = simplify expr1 sarray i
       result = ((BinaryOperation Plus (expr) (Leaf (Variable (get_subVar [expr2] sarray)))), sarray, i)
                   
print_simplify :: ExprV -> ExprV
print_simplify expr = result
 where (expr1, b, c) = simplify expr [] 0
       result = expr1


simplify :: ExprV -> [SubExpressions] ->  Int -> (ExprV, [SubExpressions], Int)
simplify (Leaf (Constant d)) sarray i = ((Leaf (Constant d)), sarray, i)
simplify (Leaf (Variable d)) sarray i = ((Leaf (Variable d)), sarray, i)
simplify (UnaryOperation Minus (expr1)) sarray i = result
 where is_in = is_subExpression_in [(expr1)] sarray
       is_expr_in = is_subExpression_in [UnaryOperation Minus (expr1)] sarray
       result =
        if is_expr_in == True
         then ((Leaf (Variable (get_subVar [(UnaryOperation Minus (expr1))] sarray))), sarray, i)
         else if is_in == True
          then ((Leaf (Variable (get_subVar [(expr1)] sarray))), sarray, i)
          else result_false
            where is_l = is_subLeaf [(expr1)] sarray
                  result_false = 
                   if is_l == True
                    then ((Leaf (Variable ("$" ++ [intToDigit i]))), (sarray ++ [Sub ("$" ++ [intToDigit i]) (UnaryOperation Minus (expr1))]), i+1)
                    else result_false_false
                     where (expr, sarray2, i2) = simplify (expr1) sarray i
                           result_false_false = ((UnaryOperation Minus (expr)), sarray2, i2)
simplify (BinaryOperation Plus (expr1) (expr2)) sarray i = result
 where is_both_in = is_subExpression_in [expr1] sarray && is_subExpression_in [expr2] sarray
       is_expr_in = is_subExpression_in [(BinaryOperation Plus (expr1) (expr2))] sarray
       result = 
        if is_expr_in == True
         then ((Leaf (Variable (get_subVar [(BinaryOperation Plus (expr1) (expr2))] sarray))), sarray, i)
         else if is_both_in == True
          then ((Leaf (Variable ("$a" ++ [intToDigit i]))), (sarray ++ [Sub ("$a" ++ [intToDigit i]) (BinaryOperation Plus (Leaf (Variable (get_subVar [expr1] sarray))) (Leaf (Variable (get_subVar [expr2] sarray))))]), i+1)
          else result_false
            where is_expr1_in = is_subExpression_in [expr1] sarray
                  is_expr2_leaf = is_subLeaf [expr2] sarray
                  is_expr2_in = is_subExpression_in [expr2] sarray
                  is_expr1_leaf = is_subLeaf [expr1] sarray
                  result_false = 
                   if is_expr1_in == True -- FIRST SET EXPR1 THENS SEN BACK TO SIMPLIFY
                    then simplify (BinaryOperation Plus (Leaf (Variable (get_subVar [expr1] sarray))) (expr2)) sarray i
                   else if is_expr1_in == False && is_expr2_in == True
                    then simplify (BinaryOperation Plus (expr1) (Leaf (Variable (get_subVar [expr2] sarray)))) sarray i
                   else if is_expr1_in == False && is_expr2_in == False && is_expr1_leaf == True && is_expr2_leaf == True
                    then ((Leaf (Variable ("$" ++ [intToDigit i]))), (sarray ++ [Sub ("$" ++ [intToDigit i]) (BinaryOperation Plus (expr1) (expr2))]), i+1)
                   else result_final_false
                        where (expr11, sarray1, i1) = simplify expr1 sarray i
                              (expr22, sarray2, i2) = simplify expr2 sarray1 i1
                              result_final_false =
                               if (is_subLeaf [expr22] sarray2) == True || (is_subLeaf [expr11] sarray2) == True
                                then simplify (BinaryOperation Plus (expr11) (expr22)) sarray2 i2
                                else ((BinaryOperation Plus (expr11) (expr22)), sarray2, i2)
simplify (BinaryOperation Times (expr1) (expr2)) sarray i = result
 where is_both_in = is_subExpression_in [expr1] sarray && is_subExpression_in [expr2] sarray
       is_expr_in = is_subExpression_in [(BinaryOperation Times (expr1) (expr2))] sarray
       result = 
        if is_expr_in == True
         then ((Leaf (Variable (get_subVar [(BinaryOperation Times (expr1) (expr2))] sarray))), sarray, i)
         else if is_both_in == True
          then ((Leaf (Variable ("$a" ++ [intToDigit i]))), (sarray ++ [Sub ("$a" ++ [intToDigit i]) (BinaryOperation Times (Leaf (Variable (get_subVar [expr1] sarray))) (Leaf (Variable (get_subVar [expr2] sarray))))]), i+1)
          else result_false
            where is_expr1_in = is_subExpression_in [expr1] sarray
                  is_expr2_leaf = is_subLeaf [expr2] sarray
                  is_expr2_in = is_subExpression_in [expr2] sarray
                  is_expr1_leaf = is_subLeaf [expr1] sarray
                  result_false = 
                   if is_expr1_in == True -- FIRST SET EXPR1 THENS SEN BACK TO SIMPLIFY
                    then simplify (BinaryOperation Times (Leaf (Variable (get_subVar [expr1] sarray))) (expr2)) sarray i
                   else if is_expr1_in == False && is_expr2_in == True
                    then simplify (BinaryOperation Times (expr1) (Leaf (Variable (get_subVar [expr2] sarray)))) sarray i
                   else if is_expr1_in == False && is_expr2_in == False && is_expr1_leaf == True && is_expr2_leaf == True
                    then ((Leaf (Variable ("$" ++ [intToDigit i]))), (sarray ++ [Sub ("$" ++ [intToDigit i]) (BinaryOperation Times (expr1) (expr2))]), i+1)
                   else result_final_false
                        where (expr11, sarray1, i1) = simplify expr1 sarray i
                              (expr22, sarray2, i2) = simplify expr2 sarray1 i1
                              result_final_false =
                               if (is_subLeaf [expr22] sarray2) == True || (is_subLeaf [expr11] sarray2) == True
                                then simplify (BinaryOperation Times (expr11) (expr22)) sarray2 i2
                                else ((BinaryOperation Times (expr11) (expr22)), sarray2, i2)

get_count :: [ExprV] -> String -> Int -> Int
get_count [] _ i = i
get_count [Leaf (Constant d)] _ i = i
get_count [Leaf (Variable d)] var i = result
 where result = 
        if d == var
         then (i+1)
         else i
get_count [UnaryOperation Minus (expr)] var i = get_count [expr] var i
get_count [BinaryOperation Plus (expr1) (expr2)] var i = (get_count [expr1] var i) + (get_count [expr2] var i) - i
get_count [BinaryOperation Times (expr1) (expr2)] var i = (get_count [expr1] var i) + (get_count [expr2] var i) - i

change_var_to_expr :: [ExprV] -> String -> [ExprV] -> ExprV
change_var_to_expr [Leaf (Constant d)] _ _ = (Leaf (Constant d))
change_var_to_expr [Leaf (Variable d)] var [expr_final] = result
 where result = 
        if d == var
         then expr_final
         else (Leaf (Variable d))
change_var_to_expr [UnaryOperation Minus (expr)] var [expr_final] = (UnaryOperation Minus (change_var_to_expr [expr] var [expr_final]))
change_var_to_expr [BinaryOperation Plus (expr1) (expr2)] var [expr_final] = (BinaryOperation Plus (change_var_to_expr [expr1] var [expr_final]) (change_var_to_expr [expr2] var [expr_final]))
change_var_to_expr [BinaryOperation Times (expr1) (expr2)] var [expr_final] = (BinaryOperation Times (change_var_to_expr [expr1] var [expr_final]) (change_var_to_expr [expr2] var [expr_final]))

is_in_expr :: String -> [ExprV] -> Bool
is_in_expr var [Leaf (Variable d)] = result
 where result = 
        if d == var
         then True
         else False
is_in_expr var [Leaf (Constant d)] = False
is_in_expr var [UnaryOperation Minus (expr1)] = is_in_expr var [expr1]
is_in_expr var [BinaryOperation Plus (expr1) (expr2)] = is_in_expr var [expr1] || is_in_expr var [expr2]
is_in_expr var [BinaryOperation Times (expr1) (expr2)] = is_in_expr var [expr1] || is_in_expr var [expr2]

is_in_subExpr :: String -> [SubExpressions] -> Bool
is_in_subExpr var [] = False
is_in_subExpr var sarray = result
 where [(Sub frst_var frst_expr)] = take 1 sarray
       rest_dropped_sarray = drop 1 sarray
       is_in = is_in_expr var [frst_expr]
       result = 
        if is_in == True
         then True
         else is_in_subExpr var rest_dropped_sarray

getRidOfUnos :: [ExprV] -> [SubExpressions] -> [SubExpressions] -> (ExprV, [SubExpressions])
getRidOfUnos [result] [] [] = (result, [])
getRidOfUnos [result] sarray [] = (result, sarray)
getRidOfUnos [expr] sarray dropped_sarray = result
 where [(Sub frst_var frst_expr)] = take 1 dropped_sarray
       rest_dropped_sarray = drop 1 dropped_sarray
       total_count = get_count [expr] frst_var 0
       result =
        if total_count > 1 || total_count == 0
         then getRidOfUnos [expr] sarray rest_dropped_sarray
         else result_false -- Check whether var exists in an sub_expr
              where is_more_than_one = is_in_subExpr frst_var sarray --------------------
                    result_false =
                     if is_more_than_one == True
                      then getRidOfUnos [expr] sarray rest_dropped_sarray
                      else result_false_false
                           where final_expr = change_var_to_expr [expr] frst_var [frst_expr]
                                 len_dropped = length rest_dropped_sarray
                                 len_original = length sarray
                                 len_first = len_original - len_dropped - 1
                                 result_false_false = 
                                  if len_first < 0
                                   then getRidOfUnos [final_expr] [] []
                                   else result_bey
                                        where sarray_p1 = take len_first sarray
                                              sarray_p2 = drop (len_first+1) sarray
                                              sarray_final = sarray_p1 ++ sarray_p2
                                              result_bey = getRidOfUnos [final_expr] sarray_final sarray_final

change_sub_to_vars :: [SubExpressions] -> [(String, ExprV)]
change_sub_to_vars [] = []
change_sub_to_vars sarray = result
 where [(Sub var (expr))] = take 1 sarray
       rest = drop 1 sarray
       result = [(var, (expr))] ++ change_sub_to_vars rest


assignCommonSubexprs :: ExprV -> ([(String, ExprV)], ExprV)
assignCommonSubexprs expr = result
 where (simplified, subExprs, i) = simplify expr [] 0
       (multiExprs, multiSubExprs) = getRidOfUnos [simplified] subExprs subExprs
       vars = change_sub_to_vars multiSubExprs
       result = (vars, multiExprs)

--------------------------------------------------------------------------------------------------
multiply_helper :: [ExprV] -> [ExprV] -> [ExprV]
multiply_helper [] [] =  []
multiply_helper [temp] [] =  []
multiply_helper [temp] second_part =  result
 where [stemp] = take 1 second_part
       srest = drop 1 second_part
       result = [BinaryOperation Times temp stemp] ++ multiply_helper [temp] srest

multiply :: [ExprV] -> [ExprV] -> [ExprV] -> [ExprV]
multiply [] [] [] = []
multiply _ [] _ = []
multiply first_part dropped_first_part second_part = result
 where temp = take 1 dropped_first_part
       rest = drop 1 dropped_first_part
       result = multiply_helper temp second_part ++ multiply first_part rest second_part

turn_to_negative :: [ExprV] -> [ExprV]
turn_to_negative [] = []
turn_to_negative [Leaf (Constant d)] = [Leaf (Constant (-d))]
turn_to_negative [Leaf (Variable d)] = result 
 where first_letter = take 1 d
       rest = drop 1 d
       result = 
        if first_letter == "-"
         then [Leaf (Variable rest)]
         else [Leaf (Variable ("-" ++ d))]
turn_to_negative expr = result
 where frst = take 1 expr
       rest = drop 1 expr
       result = turn_to_negative frst ++ turn_to_negative rest

open_bracelets :: ExprV -> [ExprV]
open_bracelets (Leaf (Constant d)) = [Leaf (Constant d)]
open_bracelets (Leaf (Variable d)) = [Leaf (Variable d)]
open_bracelets (UnaryOperation Minus expr) = result
 where expr1 = open_bracelets expr
       result = turn_to_negative expr1
open_bracelets (BinaryOperation Plus expr1 expr2) = open_bracelets expr1 ++ open_bracelets expr2
open_bracelets (BinaryOperation Times expr1 expr2) = result
 where first_part = open_bracelets expr1
       second_part = open_bracelets expr2
       result = multiply first_part first_part second_part

is_constant :: ExprV -> Bool
is_constant (Leaf (Constant d)) = True
is_constant _ = False

get_constant :: ExprV -> Int
get_constant (Leaf (Constant d)) = d

multiply_constants_helper :: ExprV -> ExprV
multiply_constants_helper (Leaf (Constant d)) = Leaf (Constant d)
multiply_constants_helper (Leaf (Variable d)) = Leaf (Variable d)
multiply_constants_helper (BinaryOperation Times (Leaf (Constant a)) (Leaf (Constant d))) = (Leaf (Constant (a*d)))
multiply_constants_helper (BinaryOperation Times (expr1) (expr2)) = result
 where expr11 = multiply_constants_helper expr1
       expr22 = multiply_constants_helper expr2
       is_expr1_constant = is_constant expr11
       is_expr2_constant = is_constant expr22
       result =
        if is_expr1_constant == False || is_expr2_constant == False
         then (BinaryOperation Times (expr11) (expr22))
         else result_true
          where a = get_constant expr11
                b = get_constant expr22
                result_true = Leaf (Constant (a*b))


multiply_constants :: [ExprV] -> [ExprV]
multiply_constants [] = []
multiply_constants expr = result
 where [frst] = take 1 expr
       rest = drop 1 expr
       result = [multiply_constants_helper frst] ++  multiply_constants rest

sum_constants :: [ExprV] -> Int -> [ExprV] -> (Int, [ExprV])
sum_constants [] sum final = result
 where result =
        if sum == 0
         then (sum, [])
         else (sum, [Leaf (Constant sum)] ++ final)
sum_constants [Leaf (Constant d)] sum final = ((d+sum), final)
sum_constants [Leaf (Variable d)] sum final = (sum, final ++ [Leaf (Variable d)])
sum_constants [BinaryOperation Times expr1 expr2] sum final = (sum, final ++ [BinaryOperation Times expr1 expr2])
sum_constants expr sum final = result
 where frst = take 1 expr
       rest = drop 1 expr
       (sum_final, final1) = sum_constants frst sum final
       result = sum_constants rest sum_final final1

data Pured = Pure Int [String]

is_in_parray :: [Pured] -> [String] -> Bool
is_in_parray [] _ = False
is_in_parray parray var = result 
 where [Pure d s] = take 1 parray
       rest = drop 1 parray
       result = 
        if s == var
         then True
         else is_in_parray rest var

increase_parray_by_d :: [Pured] -> [Pured] -> [String] -> Int -> [Pured]
increase_parray_by_d parray parray_o var d = result
 where [Pure d1 s] = take 1 parray
       rest = drop 1 parray
       result = 
        if s == var
         then (take (length parray_o - length parray) parray_o) ++ [Pure (d1+d) s] ++ rest
         else increase_parray_by_d rest parray_o var d

dummyWhere1 :: [Pured] -> [String] -> [Pured]
dummyWhere1 parray var_final = result
 where is_pured = is_in_parray parray var_final
       result = 
        if is_pured == True
         then increase_parray_by_d parray parray var_final 1
         else parray ++ [Pure 1 var_final]

get_var_final :: [ExprV] -> Int -> Int -> ([String], Int, Int)
get_var_final [] i sum = ([], i, sum)
get_var_final [Leaf (Variable var)] i sum = result
 where result =
        if (take 1 var /= "-")
         then ([var], i, (sum))
         else ([drop 1 var], (i+1), (sum*(-1)))
get_var_final [Leaf (Constant d)] i sum = ([], i, sum*d)
get_var_final [BinaryOperation Times expr1 expr2] i sum = result 
 where (expr11, i1, sum1) = get_var_final [expr1] i sum
       (expr22, i2, sum2) = get_var_final [expr2] i1 sum1
       result = ((expr11 ++ expr22), i2, sum2)

pure_times_help :: [ExprV] -> [Pured] -> Int -> [Pured]
pure_times_help [Leaf (Variable var)] parray d = result
 where is_pured = is_in_parray parray [(drop 1 var)]
       result = 
        if is_pured == True
         then increase_parray_by_d parray parray [(drop 1 var)] (-d)
         else parray ++ [Pure (-d) [(drop 1 var)]]

pure_times :: [ExprV] -> [Pured] -> [Pured]
pure_times [] parray = parray
pure_times [Leaf (Variable var)] parray = result
 where is_var_negative = ((take 1 var) == "-")
       result =
        if is_var_negative == True
         then pure_times_help [Leaf (Variable var)] parray 1
         else result_false
          where is_pured = is_in_parray parray [var]
                result_false =
                 if is_pured == True
                  then increase_parray_by_d parray parray [var] 1
                  else parray ++ [Pure 1 [var]]
pure_times [BinaryOperation Times (Leaf (Constant d)) (Leaf (Variable var))] parray = result 
 where is_var_negative = ((take 1 var) == "-")
       result =
        if is_var_negative == True
         then pure_times_help [Leaf (Variable var)] parray d
         else result_false
          where is_pured = is_in_parray parray [var]
                result_false =
                 if is_pured == True
                  then increase_parray_by_d parray parray [var] d
                  else parray ++ [Pure d [var]]
pure_times [BinaryOperation Times (Leaf (Constant d)) (expr)] parray = result 
 where (var_final, i, sum) = get_var_final [expr] 0 1
       sorted_var_final = sort var_final
       sum1 = sum*d
       is_pured = is_in_parray parray sorted_var_final
       result = 
        if is_pured == True 
         then increase_parray_by_d parray parray sorted_var_final sum1
         else parray ++ [Pure sum1 sorted_var_final]
pure_times [BinaryOperation Times (Leaf (Variable var)) (Leaf (Constant d))] parray = result 
 where is_var_negative = ((take 1 var) == "-")
       result =
        if is_var_negative == True
         then pure_times_help [Leaf (Variable var)] parray d
         else result_false
          where is_pured = is_in_parray parray [var]
                result_false =
                 if is_pured == True
                  then increase_parray_by_d parray parray [var] 1
                  else parray ++ [Pure 1 [var]]
pure_times [BinaryOperation Times (expr) (Leaf (Constant d))] parray = result 
 where (var_final, i, sum) = get_var_final [expr] 0 1
       sorted_var_final = sort var_final
       sum1 = sum*d
       is_pured = is_in_parray parray sorted_var_final
       result = 
        if is_pured == True 
         then increase_parray_by_d parray parray sorted_var_final sum1
         else parray ++ [Pure sum1 sorted_var_final]
pure_times [BinaryOperation Times (Leaf (Variable var1)) (Leaf (Variable var2))] parray = result 
 where result =
        if var1 < var2
         then dummyWhere1 parray ([var1] ++ [var2])
         else dummyWhere1 parray ([var2] ++ [var1])
pure_times [BinaryOperation Times (expr1) (expr2)] parray = result 
 where (var1_final, i1, sum1) = get_var_final [expr1] 0 1
       (var2_final, i2, sum2) = get_var_final [expr2] 0 1
       var_final = var1_final ++ var2_final
       sorted_var_final = sort var_final
       sum_final = sum1*sum2
       is_pured = is_in_parray parray sorted_var_final
       result = 
        if is_pured == True 
         then increase_parray_by_d parray parray sorted_var_final sum_final
         else parray ++ [Pure sum_final sorted_var_final]
pure_times exprs parray = result 
 where frst = take 1 exprs
       rest = drop 1 exprs
       aparray = pure_times frst parray
       result = pure_times rest aparray

dummyWhere2 :: [Pured] -> ExprV
dummyWhere2 [Pure d [temp]] = result
 where result =
        if d == -1
         then UnaryOperation Minus (Leaf (Variable temp))
         else BinaryOperation Times (Leaf (Constant d)) (Leaf (Variable temp))

make_pure_expr_helper :: [Pured] -> ExprV
make_pure_expr_helper [Pure d vars] = result 
 where result = 
        if length vars == 1
         then dummyWhere2 [Pure d vars]
         else result_false
          where rest = take (length vars - 1) vars
                [frst] = drop (length vars - 1) vars
                result_false = (BinaryOperation Times (make_pure_expr_helper [Pure d rest]) (Leaf (Variable frst)))


make_pure_expr :: [Pured] -> [ExprV]
make_pure_expr [] = []
make_pure_expr parray = result
 where frst = take 1 parray
       rest = drop 1 parray 
       result = [make_pure_expr_helper frst] ++ make_pure_expr rest

sum_the_list :: [ExprV] -> ExprV
sum_the_list exprs = result
 where result = 
        if length exprs == 0
         then Leaf (Constant 0)
         else result_false
          where [frst] = drop (length exprs - 1) exprs
                rest = take (length exprs -1) exprs
                result_false =
                 if length rest == 0
                  then (frst)
                  else BinaryOperation Plus (sum_the_list rest) (frst)

bored :: [ExprV] -> [ExprV]
bored [BinaryOperation Times (Leaf (Constant d)) (expr22)] = result
 where result = 
        if d == 0
         then []
         else if d == 1
         then [expr22]
         else [BinaryOperation Times (Leaf (Constant d)) (expr22)]

boredv2 :: [ExprV] -> [ExprV]
boredv2 [BinaryOperation Times (Leaf (Constant d)) (Leaf (Constant f))] = result
 where result = 
        if d == 0 || f == 0
         then []
         else if d == 1 && f == 1
         then []
         else if f == 1
         then [(Leaf (Constant d))]
         else if d == 1
         then [(Leaf (Constant f))]
         else [BinaryOperation Times (Leaf (Constant d)) (Leaf (Constant f))]

get_rid_of_ones_and_zeros :: [ExprV] -> [ExprV]
get_rid_of_ones_and_zeros [] = []
get_rid_of_ones_and_zeros [Leaf (Variable var)] = [Leaf (Variable var)]
get_rid_of_ones_and_zeros [Leaf (Constant d)] = [Leaf (Constant d)]
get_rid_of_ones_and_zeros [BinaryOperation Times (Leaf (Constant 0)) expr] = []
get_rid_of_ones_and_zeros [BinaryOperation Times expr (Leaf (Constant 0))] = []
get_rid_of_ones_and_zeros [BinaryOperation Times expr (Leaf (Constant 1))] = get_rid_of_ones_and_zeros [expr]
get_rid_of_ones_and_zeros [BinaryOperation Times (Leaf (Constant 1)) expr] = get_rid_of_ones_and_zeros [expr]
get_rid_of_ones_and_zeros [BinaryOperation Times expr1 expr2] = result
 where [expr11] = get_rid_of_ones_and_zeros [expr1]
       [expr22] = get_rid_of_ones_and_zeros [expr2]
       result =
        if is_constant expr11 == False && is_constant expr22 == False
         then [BinaryOperation Times (expr11) (expr22)]
         else result_true
          where is_1_constant = is_constant expr11
                is_2_constant = is_constant expr22
                result_true =
                 if (is_1_constant == True && is_2_constant == False)
                  then bored [BinaryOperation Times (expr11) (expr22)]
                  else if (is_1_constant == True && is_2_constant == True)
                  then boredv2 [BinaryOperation Times (expr11) (expr22)]
                  else bored [BinaryOperation Times (expr22) (expr11)]
get_rid_of_ones_and_zeros exprs = result
 where frst = take 1 exprs
       rest = drop 1 exprs
       result = get_rid_of_ones_and_zeros frst ++ get_rid_of_ones_and_zeros rest

data Order = Order Int ExprV

append_to_ordered :: [ExprV] -> Int -> [Order] -> [Order] -> [Order]
append_to_ordered [frst] len_frst ordered [] = ordered ++ [Order len_frst frst]
append_to_ordered [frst] len_frst ordered dropped_ordered = result 
 where [Order len expr] = take 1 dropped_ordered
       rest = drop 1 dropped_ordered
       result = 
        if len < len_frst
         then append_to_ordered [frst] len_frst ordered rest
         else result_true
          where len_o = length ordered
                len_d = length dropped_ordered
                part1 = take (len_o - len_d) ordered
                result_true = part1 ++ [Order len_frst frst] ++ dropped_ordered
 
order_by_length_helper :: [ExprV] -> [Order] -> [Order]
order_by_length_helper [] ordered = ordered
order_by_length_helper exprs ordered = result 
 where [frst] = take 1 exprs 
       rest = drop 1 exprs
       len_frst = expr_len [frst]
       final = append_to_ordered [frst] len_frst ordered ordered
       result = order_by_length_helper rest final

expr_len :: [ExprV] -> Int
expr_len [] = 0
expr_len [Leaf (Variable d)] = 1
expr_len [Leaf (Constant d)] = 0
expr_len [BinaryOperation Times (expr1) (expr2)] = expr_len [expr1] + expr_len [expr2]

order_to_expr :: [Order] -> [ExprV] -> [ExprV]
order_to_expr [] expr = expr
order_to_expr ordered tobe = result
 where [(Order len expr)] = take 1 ordered
       rest = drop 1 ordered
       final_expr = tobe ++ [expr]
       result = order_to_expr rest final_expr

order_by_length :: [ExprV] -> [ExprV]
order_by_length [] = []
order_by_length exprs = result 
 where [frst] = take 1 exprs 
       rest = drop 1 exprs
       len_frst = expr_len [frst]
       ordered = [Order len_frst frst]
       list = order_by_length_helper rest ordered
       result = order_to_expr list []

reducePoly :: ExprV -> ExprV
reducePoly expr = result
 where without_bracelets = open_bracelets expr
       mult_constants = multiply_constants without_bracelets
       (sum, sum_vars) = sum_constants mult_constants 0 []
       finalv08 = pure_times sum_vars []
       finalv085 = make_pure_expr finalv08
       finalv086 = get_rid_of_ones_and_zeros finalv085
       finalv09 = order_by_length finalv086
       result =
        if sum == 0
         then sum_the_list finalv09
         else sum_the_list ([Leaf (Constant sum)] ++ finalv09)

-- an extra dummy variable, so as to not crash the GUI
notImpl :: ExprV
notImpl = Leaf $ Variable "Not Implemented"

