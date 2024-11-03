# PFL_24_T03_G01 - Project 1

## Group Members
- Gonçalo Remelhe, 202205318 (50%) Implemented both the shortestPath and the travelSales function.
- Joana Noites, 202206284 (50%) Implemented the cities, areAdjacent, distance, adjacent, pathDistance, rome and isStronglyConnected functions.

## shortestPath function
To compute the shortest path between 2 given cities, 3 auxiliary functions were used: dijsktra, adjacentArray and dfsAllShortestPaths.

### Auxiliary function 1: Dijsktra

The dijsktra function finds the shortest distance between 2 cities, to do this, it converts the given roadmap to an **auxiliar data strucuture: newRoadMap**, obtained by the **roadArray** function, which stores the distances between pairs of cities if there is a road between them or Nothing if there isn't. It consists of an array of pairs that functions as a matrix, the first element of each entry is a pair of cities and the second element is the distance between them.

After converting the given roadmap to a roadArray, the dijkstra function makes use of the toCityIndex function (that returns an array of pairs in the format (city, index) ) to store the number of cities in the roadmap and the indices of the starting and target cities.

Then the arrays distanceArray and visited are created, distanceArray is used to keep track of each city and its distance from the starting city (every distance (except the distance of the starting city) is initialized as "maxbound") and visited keeps track of the cities that were already visited.

After this, the creation of an auxiliary function inside the original dijsktra function is needed, this auxiliary function is named dijsktra' and it takes the visited array and distanceArray as parameters as well as an array with only a tuple (starting city,0) that's going to serve as the start of a queue. In a nutshell, this auxiliary function: 1.Finds the city with the shortest distance relatively to the starting city (the second element of the pairs in the queue), 2.removes it from the queue, 3.marks that city as visited, 4.finds the unvisited neighbours of that city, 5.updates their distances in relation to the starting city, 6. updates the queue and finally 7. continues recursively with a new queue and a new distance array until the queue is empty and finally 8. returns the distance to the target city. The return value of this auxiliary function is the return value of the original dijsktra function, however a check is ran to see if it is equal to the "maxbound" defined in the distance array, if so, dijsktra returns Nothing, as this means that the target city is not accessible from the starting city.

### Auxiliary function 2: adjacentArray

adjacentArray is a different approach to the adjacent function, the difference being that it uses the auxiliar data structure newRoadMap defined by the **roadArray** function explained above.

### Auxiliary function 3: dfsAllShortestPaths

This function uses Depth-First search to find all the shortest paths between 2 cities. It uses the auxiliar data structure newRoadMap, the cityIndex array obtained from the tocityindex function, the indexes from the starting and ending city, as well as the return value of the dijkstra function mentioned above. This function performs depth first search and registers the paths from the starting city to the ending city, when a path is concluded, it is checked if its distance is longer than the value returned by dijsktra (mindist), if so, the path is discarded, otherwise, the path is saved and more paths are calculated recursively until all possible cases are exhausted. Then all the shortest paths are returned as an array of arrays of pairs. 

### Result

Finally, with all these auxiliary functions defined the shortestPath function can calculate the minimum distance using dijsktra and find all the paths from the starting city to the ending city measuring the minimum distance with the use of the dfsAllShortestPaths (that uses the adjacent array for the path searching).

## travelSales function
To solve the travelling salesperson problem, 2 auxiliary functions were used:

### Auxiliary function 1: tsp
This function uses dynamic programming and bit masking to solve the travelling salesperson problem, it is the body of the travelSales function and takes the following parameters: a **newRoadMap**, the number of cities, a bitmask marking the represented cities, the current position of the TSP traversal and a dynamic table that stores previously calculated optimal paths.

Firstly, the base case checks if all cities were visited, if so, the function returns the calculated path (keeping in mind that we need to return to the starting city at the end), if not the function checks if it is already stored in the dynamic table.

If the result is indeed already stored, it is returned, if not, the function computes all possible results by visiting the next univisited city, this is done by firstly checking if the next city is unvisited, if so, the function makes a recursive call with an updated bitmask (that now marks this next city as visited) and the distance is calculated by incrementing the current distance to the previously calculated distance value. Once all possible results are computed, the function selects the path with the minimum distance using minimumBy and a custom comparator function compareResult. If no valid path is found, it defaults to (Nothing, []). The best result is stored in dynamicTable at (pos, mask) and then this enry is returned.

### Auxiliary function 2: comparison function
This function is used to compare two potential results, handling both Nothing and Just values in a way that prioritizes valid paths (Just values) over non-existent paths (Nothing values). It enables the tsp function to easily find the shortest valid path from a list of possible paths. It has 3 use cases:

1.When both results are Nothing, they are considered equal, as neither represents a valid path.

2.If one of the results is Nothing and the other is Just, the result with Just is considered smaller.

3.When both results are Just values, it directly compares their distances (c1 and c2).


### Result

Finally, with all these auxiliary functions defined the main function travelSales can compute the optimal path that visits each city exactly once and returns to the starting city. It first makes use of the toCityIndex and roadArray functions mentioned above to obtain the (city, index) array (cityIdx) the new roadmap (roadMap) and the number of cities (n), then the dynamic table is initialized as a 2D array where each entry is indexed by (i, s) with i representing the current city index and s as a bit mask encoding the set of visited cities. All entries are initially initialized with (Nothing, []), meaning no paths are computed initially.  The function then calls the recursive tsp function to solve the TSP from the starting position, passing roadMap as the matrix of city-to-city distances, n as the total number of cities, 1 as the initial mask (only the starting city has been visited), 0 as the starting city position, and dynamicTable as the dynamic programming table. Finally, travelSales processes the result of this computation. If no valid path exists, it returns an empty list; otherwise, it maps each city index in the computed path back to its corresponding city name in cityIdx, appending the starting city to the end of the path to complete the round trip. The result is a list of city names representing the optimal route for the Traveling Salesperson Problem.



