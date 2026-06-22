const sql       = require('mssql');
const { getPool } = require('./db.service');
const qry         = require('../sql/qryExtranet');

/**
 * Upload un document dans StdDocument.
 * Utilise mssql directement pour gérer le type VARBINARY(MAX).
 */
const upload = async (userId, token, nature, identifiant, type, documentBuffer) => {
    const pool    = await getPool();
    const request = pool.request();

    request.input('userId',      sql.Int,            userId);
    request.input('token',       sql.VarChar(sql.MAX), token);
    request.input('nature',      sql.VarChar(50),    nature);
    request.input('identifiant', sql.Int,            identifiant);
    request.input('type',        sql.VarChar(255),   type);
    request.input('document',    sql.VarBinary(sql.MAX), documentBuffer);

    const result = await request.query(qry.uploadDocument);
    return result.recordsets;
};

/**
 * Récupère la liste des documents (admin uniquement).
 */
const getDocuments = async (userId, token, source, nature, identifiant, dateFrom, dateTo) => {
    const pool    = await getPool();
    const request = pool.request();

    request.input('userId',      sql.Int,              userId);
    request.input('token',       sql.VarChar(sql.MAX), token);
    request.input('source',      sql.VarChar(10),      source);
    request.input('nature',      sql.VarChar(50),      nature   || null);
    request.input('identifiant', sql.Int,              identifiant ? parseInt(identifiant) : null);
    request.input('dateFrom',    sql.Date,             dateFrom || null);
    request.input('dateTo',      sql.Date,             dateTo   || null);

    const result = await request.query(qry.getDocuments);
    return result.recordsets;
};

/**
 * Récupère le contenu binaire d'un document par son Id.
 */
const getDocumentById = async (userId, token, source, documentId) => {
    const pool    = await getPool();
    const request = pool.request();

    request.input('userId',     sql.Int,              userId);
    request.input('token',      sql.VarChar(sql.MAX), token);
    request.input('source',     sql.VarChar(10),      source);
    request.input('documentId', sql.Int,              documentId);

    const result = await request.query(qry.getDocumentById);
    return result.recordsets;
};

/**
 * Supprime un document par son Id.
 */
const deleteDocument = async (userId, token, source, documentId) => {
    const pool    = await getPool();
    const request = pool.request();

    request.input('userId',     sql.Int,              userId);
    request.input('token',      sql.VarChar(sql.MAX), token);
    request.input('source',     sql.VarChar(10),      source);
    request.input('documentId', sql.Int,              documentId);

    const result = await request.query(qry.deleteDocument);
    return result.recordsets;
};

/**
 * Met à jour le statut transféré d'un document par son Id.
 */
const updateDocumentTransfere = async (userId, token, source, documentId, transfere) => {
    const pool    = await getPool();
    const request = pool.request();

    request.input('userId',     sql.Int,              userId);
    request.input('token',      sql.VarChar(sql.MAX), token);
    request.input('source',     sql.VarChar(10),      source);
    request.input('documentId', sql.Int,              documentId);
    request.input('transfere',  sql.Char(1),          transfere);

    const result = await request.query(qry.updateDocumentTransfere);
    return result.recordsets;
};

module.exports = { upload, getDocuments, getDocumentById, deleteDocument, updateDocumentTransfere };
