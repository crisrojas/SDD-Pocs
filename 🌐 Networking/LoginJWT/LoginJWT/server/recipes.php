<?php
    
    function getRecipes() {
        $recipes = [];
        $file = fopen('db/recipes.csv', 'r');
        while ($row = fgetcsv($file)) {
            $recipe = array_map('trim', $row);
            $recipes[] = [
                'id' => $recipe[0],
                'title' => $recipe[1],
                'userId' => $recipe[2],
            ];
        }
        fclose($file);
        return $recipes;
    }

    function getUserRecipes($id) {
        $recipes = getRecipes();
        $userRecipes = array_filter($recipes, function($recipe) use ($id) {
            return $recipe['userId'] == $id;
        });
        return $userRecipes;
    }

    
    function createRecipe($userId, $title) {
        $recipes = getRecipes();
        $id = count($recipes) + 1;
        $recipe = [ 
            'id' => $id,
            'title' => $title,
            'userId' => $userId
        ];
        $recipes[] = $recipe;
        saveRecipes($recipes);
        return $recipe;
     }
    
    function saveRecipes($recipes) {
        $file = fopen('db/recipes.csv', 'w');
        foreach ($recipes as $recipe) {
            fputcsv($file, $recipe);
        }
        fclose($file);
    }

    function test_get_user_recipes() {
        $recipes = getUserRecipes(2);
        echo json_encode($recipes);
        createRecipe(3, 'Avocado salad');
    }
    
    // test()
?>
