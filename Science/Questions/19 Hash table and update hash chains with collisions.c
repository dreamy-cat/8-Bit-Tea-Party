#include <stdio.h>
#include <stdlib.h>

int main()
{
    /* Упражнение 1.
     * Вставьте ключи: 5, 82, 19, 51, 20, 33, 12, 107, 10.
     * в хеш-таблицу с разрешением коллизий методом цепочек.
     * Таблица имеет m ячеек, а хеш функция имеет вид h(k) = k mod m.
     * Вариант 3, параметр m = 31.
     */

#define HASH_MAX 256

    struct hash_chain {
        int keys;
        int hash;
        int data_index;
    };

    struct hash_chain hash_table[HASH_MAX];
    int hash_data[HASH_MAX];

    // int values[10] = { ... данные из условия. }
    int values[10];
    int m = 31, keys = sizeof(values) / sizeof(int), table_size = 0;
    keys = 10; m = 5;   // Debug.
    printf("Variant with random keys.\n");
    printf("Hash chain parameter M = %d, %d keys to insert.\n", m, keys);
    for (int i = 0; i < keys; ++i) {
        values[i] = rand() % 10;
        printf("%d ", values[i]);
    }
    printf("\n");
    printf("Hash function is H(key) = key mod M.\n");
    printf("Inserting values to empty hash table.\n");

    for (int i = 0, j, k, is_collision; i < keys; ++i) {
        int hash = values[i] % 5;
        printf("\nHash H(%d) = %d, searching for collision in table.\n", values[i], hash);
        printf("Hash in table:\tHash:\tChain size:\tChain:");
        for (j = 0, is_collision = 0; j < table_size && !is_collision; ) {
            printf("\n%d:\t\t%d\t%d\t\t", j, hash_table[j].hash, hash_table[j].keys);
            for (k = 0; k < hash_table[j].keys; ++k)
                printf("%d ", hash_data[hash_table[j].data_index + k]);
            if (hash_table[j].hash == hash)
                is_collision = 1;
            else
                j++;
        }
        if (is_collision) {
            printf("\nCollision is founded at %d record, index data %d and chain size %d.\n",
                   j, hash_table[j].data_index, hash_table[j].keys);
            for (k = HASH_MAX - 1; k > hash_table[j].data_index; --k)
                hash_data[k] = hash_data[k - 1];
            hash_data[hash_table[j].data_index] = values[i];
            hash_table[j].keys++;
            printf("Update chain in table. Record %d, data size %d, hash %d and keys chain: ",
                   j, hash_table[j].keys, hash_table[j].hash);
            for (k = 0; k < hash_table[j].keys; ++k)
                printf("%d ", hash_data[hash_table[j].data_index + k]);
            printf("\n");
        } else {
            printf("\nCollision is not founded in table, first free record %d.\n", j);
            hash_table[j].keys = 1;
            hash_table[j].hash = hash;
            if (table_size)
                hash_table[j].data_index = hash_table[j - 1].data_index + hash_table[j].keys;
            else
                hash_table[j].data_index = 0;
            hash_data[hash_table[j].data_index] = values[i];
            printf("Add new hash %d to table for key %d and data size %d at index %d.\n",
                   hash, values[i], hash_table[j].keys, hash_table[j].data_index);
            table_size++;
        }
    }

    printf("\n");
    printf("Hash table result with chains.\n");
    printf("Hash in table:\tHash:\tData index:\tChain:");
    for (int i = 0; i < table_size; ++i) {
        printf("\n%d:\t\t%d\t%d\t\t", i, hash_table[i].hash, hash_table[i].data_index);
        for (int k = 0; k < hash_table[i].keys; ++k)
            printf("%d ", hash_data[hash_table[i].data_index + k]);
    }
    printf("\n");
    return 0;
}
