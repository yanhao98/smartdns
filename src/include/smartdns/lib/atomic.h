/*************************************************************************
 *
 * Copyright (C) 2018-2025 Ruilin Peng (Nick) <pymumu@gmail.com>.
 *
 * smartdns is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * smartdns is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef _GENERIC_ATOMIC_H
#define _GENERIC_ATOMIC_H

/**
 * Atomic type.
 */
typedef struct {
	long counter;
} atomic_t;

#define ATOMIC_INIT(i) {(i)}

/**
 * Read atomic variable
 * @param v pointer of type atomic_t
 *
 * Atomically reads the value of @v.
 */
static inline long atomic_read(const atomic_t *v)
{
	return __atomic_load_n(&v->counter, __ATOMIC_SEQ_CST);
}

/**
 * Set atomic variable
 * @param v pointer of type atomic_t
 * @param i required value
 */
static inline void atomic_set(atomic_t *v, long i)
{
	__atomic_store_n(&v->counter, i, __ATOMIC_SEQ_CST);
}

/**
 * Add to the atomic variable
 * @param i integer value to add
 * @param v pointer of type atomic_t
 */
static inline void atomic_add(long i, atomic_t *v)
{
	__atomic_add_fetch(&v->counter, i, __ATOMIC_SEQ_CST);
}

/**
 * Subtract the atomic variable
 * @param i integer value to subtract
 * @param v pointer of type atomic_t
 *
 * Atomically subtracts @i from @v.
 */
static inline void atomic_sub(long i, atomic_t *v)
{
	__atomic_sub_fetch(&v->counter, i, __ATOMIC_SEQ_CST);
}

/**
 * Subtract value from variable and test result
 * @param i integer value to subtract
 * @param v pointer of type atomic_t
 *
 * Atomically subtracts @i from @v and returns
 * true if the result is zero, or false for all
 * other cases.
 */
static inline long atomic_sub_and_test(long i, atomic_t *v)
{
	return !(__atomic_sub_fetch(&v->counter, i, __ATOMIC_SEQ_CST));
}

/**
 * Increment atomic variable
 * @param v pointer of type atomic_t
 *
 * Atomically increments @v by 1.
 */
static inline void atomic_inc(atomic_t *v)
{
	__atomic_add_fetch(&v->counter, 1, __ATOMIC_SEQ_CST);
}

/**
 * @brief decrement atomic variable
 * @param v: pointer of type atomic_t
 *
 * Atomically decrements @v by 1.  Note that the guaranteed
 * useful range of an atomic_t is only 24 bits.
 */
static inline void atomic_dec(atomic_t *v)
{
	__atomic_sub_fetch(&v->counter, 1, __ATOMIC_SEQ_CST);
}

/**
 * Increment atomic variable
 * @param v pointer of type atomic_t
 *
 * Atomically increments @v by 1.
 */
static inline long atomic_inc_return(atomic_t *v)
{
	return __atomic_add_fetch(&v->counter, 1, __ATOMIC_SEQ_CST);
}

/**
 * @brief decrement atomic variable
 * @param v: pointer of type atomic_t
 *
 * Atomically decrements @v by 1.  Note that the guaranteed
 * useful range of an atomic_t is only 24 bits.
 */
static inline long atomic_dec_return(atomic_t *v)
{
	return __atomic_sub_fetch(&v->counter, 1, __ATOMIC_SEQ_CST);
}

/**
 * @brief Decrement and test
 * @param v pointer of type atomic_t
 *
 * Atomically decrements @v by 1 and
 * returns true if the result is 0, or false for all other
 * cases.
 */
static inline long atomic_dec_and_test(atomic_t *v)
{
	return !(__atomic_sub_fetch(&v->counter, 1, __ATOMIC_SEQ_CST));
}

/**
 * @brief Increment and test
 * @param v pointer of type atomic_t
 *
 * Atomically increments @v by 1
 * and returns true if the result is zero, or false for all
 * other cases.
 */
static inline long atomic_inc_and_test(atomic_t *v)
{
	return !(__atomic_add_fetch(&v->counter, 1, __ATOMIC_SEQ_CST));
}

/**
 * @brief add and test if negative
 * @param v pointer of type atomic_t
 * @param i integer value to add
 *
 * Atomically adds @i to @v and returns true
 * if the result is negative, or false when
 * result is greater than or equal to zero.
 */
static inline long atomic_add_negative(long i, atomic_t *v)
{
	return (__atomic_add_fetch(&v->counter, i, __ATOMIC_SEQ_CST) < 0);
}

#endif
